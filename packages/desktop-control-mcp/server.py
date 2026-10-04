"""MCP server that lets Claude see and control a Wayland session.

Every tool takes a target (default from DESKTOP_CONTROL_TARGET, else
"workspace"); both are served by this one process:

- "workspace" (default): Claude's own nested sway session, shown as a window
  on the niri desktop and run by the claude-workspace user service. It has
  its own seat, so Claude's cursor and keyboard focus are separate from the
  user's: the user keeps full control of every other window. The pointer is
  driven through sway IPC.
- "desktop": the user's niri desktop itself. There is only one seat, so
  input there shares the user's cursor and keyboard focus; screenshots are
  harmless. The pointer is a uinput
  *absolute* device spanning niri's logical layout, so a coordinate lands on
  the same pixel regardless of pointer acceleration.

In both, screenshots come from grim and keyboard input from wtype (Wayland
virtual keyboard, full Unicode). Coordinates passed to the pointer tools refer
to the most recent screenshot.

The MCP stdio protocol (newline-delimited JSON-RPC) and the uinput device
are implemented with the standard library alone, to keep memory and the
closure small.
"""

import base64
import fcntl
import glob
import json
import math
import os
import shutil
import struct
import subprocess
import sys
import time

# Claude's vision works best at <= 1568 px on the long edge and ~1.15 MP.
MAX_EDGE = 1568
MAX_PIXELS = 1_150_000

os.environ.setdefault("YDOTOOL_SOCKET", "/run/ydotoold/socket")


def _discover_session_env():
    """MCP clients may launch servers with a minimal environment, so find the
    Wayland and niri sockets in the runtime dir when they aren't inherited."""
    runtime = os.environ.setdefault("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    if "WAYLAND_DISPLAY" not in os.environ:
        displays = sorted(glob.glob(os.path.join(runtime, "wayland-[0-9]")))
        if displays:
            os.environ["WAYLAND_DISPLAY"] = os.path.basename(displays[0])
    if "NIRI_SOCKET" not in os.environ:
        sockets = glob.glob(os.path.join(runtime, "niri.*.sock"))
        if sockets:
            os.environ["NIRI_SOCKET"] = max(sockets, key=os.path.getmtime)


def _bin(name):
    path = shutil.which(name) or f"/run/current-system/sw/bin/{name}"
    if not os.path.exists(path):
        raise RuntimeError(f"{name} not found in PATH")
    return path


def _run(*args, input=None, env=None):
    result = subprocess.run(
        [_bin(args[0]), *args[1:]], input=input, capture_output=True, timeout=30, env=env
    )
    if result.returncode != 0:
        err = result.stderr.decode(errors="replace").strip()
        raise RuntimeError(f"{args[0]} failed: {err}")
    return result.stdout


def _bounds(rects):
    x0 = min(r["x"] for r in rects)
    y0 = min(r["y"] for r in rects)
    x1 = max(r["x"] + r["width"] for r in rects)
    y1 = max(r["y"] + r["height"] for r in rects)
    return x0, y0, x1 - x0, y1 - y0


# Minimal uinput (linux/uinput.h) for an absolute pointer.
EV_SYN, EV_KEY, EV_ABS = 0x00, 0x01, 0x03
ABS_X, ABS_Y = 0x00, 0x01
BUTTONS = {"left": 0x110, "right": 0x111, "middle": 0x112}
UI_DEV_CREATE, UI_DEV_DESTROY = 0x5501, 0x5502
UI_DEV_SETUP = 0x405C5503  # _IOW('U', 3, struct uinput_setup)
UI_ABS_SETUP = 0x401C5504  # _IOW('U', 4, struct uinput_abs_setup)
UI_SET_EVBIT, UI_SET_KEYBIT, UI_SET_ABSBIT = 0x40045564, 0x40045565, 0x40045567


class AbsPointer:
    def __init__(self, width, height):
        try:
            self.fd = os.open("/dev/uinput", os.O_WRONLY | os.O_NONBLOCK)
        except PermissionError as e:
            raise RuntimeError(
                "No write access to /dev/uinput: add the user to the 'uinput' "
                "group, rebuild NixOS, and log in again."
            ) from e
        for ev in (EV_KEY, EV_ABS):
            fcntl.ioctl(self.fd, UI_SET_EVBIT, ev)
        for code in BUTTONS.values():
            fcntl.ioctl(self.fd, UI_SET_KEYBIT, code)
        for axis, size in ((ABS_X, width), (ABS_Y, height)):
            fcntl.ioctl(self.fd, UI_SET_ABSBIT, axis)
            # code; absinfo: value, min, max, fuzz, flat, resolution
            fcntl.ioctl(self.fd, UI_ABS_SETUP, struct.pack("Hxx6i", axis, 0, 0, size - 1, 0, 0, 1))
        # input_id (BUS_VIRTUAL), name, ff_effects_max
        name = b"desktop-control-mcp absolute pointer"
        fcntl.ioctl(self.fd, UI_DEV_SETUP, struct.pack("4H80sI", 0x06, 0, 0, 0, name, 0))
        fcntl.ioctl(self.fd, UI_DEV_CREATE)

    def emit(self, *events):
        data = b"".join(struct.pack("llHHi", 0, 0, *e) for e in events)
        os.write(self.fd, data + struct.pack("llHHi", 0, 0, EV_SYN, 0, 0))

    def close(self):
        fcntl.ioctl(self.fd, UI_DEV_DESTROY)
        os.close(self.fd)


class Desktop:
    """The user's niri desktop, sharing the user's single seat."""

    name = "your desktop"

    def __init__(self):
        self.device = None
        self.bounds = None

    def env(self):
        return None

    def _niri(self, *args):
        return json.loads(_run("niri", "msg", "--json", *args))

    def outputs(self):
        return {
            name: out["logical"]
            for name, out in self._niri("outputs").items()
            if out.get("logical")
        }

    def _ensure_device(self):
        bounds = _bounds(self.outputs().values())
        if self.device is not None and bounds == self.bounds:
            return
        if self.device is not None:
            self.device.close()
        _, _, width, height = bounds
        # Not marked INPUT_PROP_DIRECT: niri would treat it as a touchscreen
        # and skew the mapping. As a plain absolute pointer, its axes map 1:1
        # onto the logical layout (measured within ~2 px on both outputs).
        self.device = AbsPointer(width, height)
        self.bounds = bounds
        # Let libinput enumerate the new device before the first event.
        time.sleep(0.5)

    def move(self, gx, gy):
        self._ensure_device()
        x0, y0, width, height = self.bounds
        x = min(max(round(gx - x0), 0), width - 1)
        y = min(max(round(gy - y0), 0), height - 1)
        self.device.emit((EV_ABS, ABS_X, x), (EV_ABS, ABS_Y, y))
        time.sleep(0.03)

    def button(self, name, pressed):
        self.device.emit((EV_KEY, BUTTONS[name], 1 if pressed else 0))
        time.sleep(0.03)

    def wheel(self, direction, n):
        dx, dy = {"up": (0, 1), "down": (0, -1), "left": (-1, 0), "right": (1, 0)}[direction]
        _run("ydotool", "mousemove", "--wheel", "--", str(dx * n), str(dy * n))

    def windows(self):
        return [
            {k: w.get(k) for k in ("id", "app_id", "title", "is_focused")}
            for w in self._niri("windows")
        ]

    def focus(self, window_id):
        _run("niri", "msg", "action", "focus-window", "--id", str(window_id))

    def launch(self, command):
        _run("niri", "msg", "action", "spawn-sh", "--", command)


class Workspace:
    """Claude's nested sway session, with a seat separate from the user's."""

    name = "Claude's workspace"
    ENV_FILE = "claude-workspace.env"

    def env(self):
        path = os.path.join(os.environ["XDG_RUNTIME_DIR"], self.ENV_FILE)
        for attempt in range(2):
            try:
                with open(path) as f:
                    sock, display = f.read().split()
                if os.path.exists(sock):
                    return {**os.environ, "SWAYSOCK": sock, "WAYLAND_DISPLAY": display}
            except (FileNotFoundError, ValueError):
                pass
            if attempt == 0:
                _run("systemctl", "--user", "start", "claude-workspace.service")
                for _ in range(40):
                    if os.path.exists(path):
                        break
                    time.sleep(0.25)
        raise RuntimeError(
            "Claude's workspace did not start; see journalctl --user -u claude-workspace"
        )

    def _sway(self, *args):
        return json.loads(_run("swaymsg", "-r", *args, env=self.env()))

    def outputs(self):
        return {o["name"]: o["rect"] for o in self._sway("-t", "get_outputs") if o["active"]}

    def move(self, gx, gy):
        self._sway(f"seat seat0 cursor set {round(gx)} {round(gy)}")

    def button(self, name, pressed):
        number = {"left": 1, "middle": 2, "right": 3}[name]
        self._sway(f"seat seat0 cursor {'press' if pressed else 'release'} button{number}")

    def wheel(self, direction, n):
        # sway maps X11 buttons 4-7 to scroll axes.
        number = {"up": 4, "down": 5, "left": 6, "right": 7}[direction]
        for _ in range(n):
            self._sway(f"seat seat0 cursor press button{number}")

    def windows(self):
        found = []

        def walk(node):
            if node.get("pid"):
                found.append({
                    "id": node["id"],
                    "app_id": node.get("app_id") or (node.get("window_properties") or {}).get("class"),
                    "title": node.get("name"),
                    "is_focused": node.get("focused"),
                })
            for child in node.get("nodes", []) + node.get("floating_nodes", []):
                walk(child)

        walk(self._sway("-t", "get_tree"))
        return found

    def focus(self, window_id):
        self._sway(f"[con_id={int(window_id)}] focus")

    def launch(self, command):
        self._sway(f"exec {command}")


TARGETS = {"workspace": Workspace(), "desktop": Desktop()}
DEFAULT_TARGET = os.environ.get("DESKTOP_CONTROL_TARGET", "workspace")

# Per target: mapping from its last screenshot's pixels to logical coordinates.
views = {}


def _target(name):
    name = name or DEFAULT_TARGET
    if name not in TARGETS:
        raise ValueError(f"target must be one of {', '.join(TARGETS)}")
    return name, TARGETS[name]


def _to_global(target, x, y):
    view = views.get(target)
    if view is None:
        raise RuntimeError(f"Take a screenshot of the {target} first; coordinates refer to it.")
    if not (0 <= x < view["width"] and 0 <= y < view["height"]):
        raise ValueError(
            f"({x}, {y}) is outside the {view['width']}x{view['height']} screenshot"
        )
    return view["x"] + x / view["scale"], view["y"] + y / view["scale"]


def _png_size(data):
    return int.from_bytes(data[16:20], "big"), int.from_bytes(data[20:24], "big")


def screenshot(output=None, show_cursor=True, target=None):
    name, t = _target(target)
    outputs = t.outputs()
    if output is None:
        x0, y0, width, height = _bounds(outputs.values())
        args = []
    elif output in outputs:
        r = outputs[output]
        x0, y0, width, height = r["x"], r["y"], r["width"], r["height"]
        args = ["-o", output]
    else:
        raise ValueError(f"Unknown output {output!r}; known: {', '.join(outputs)}")

    # grim's -s scales relative to logical pixels, so HiDPI outputs are
    # normalised and downscaled in one step.
    scale = min(1.0, MAX_EDGE / max(width, height), math.sqrt(MAX_PIXELS / (width * height)))
    cursor = ["-c"] if show_cursor else []
    png = _run("grim", *cursor, "-s", f"{scale:.4f}", *args, "-t", "png", "-", env=t.env())
    size = _png_size(png)

    views[name] = {"x": x0, "y": y0, "scale": size[0] / width, "width": size[0], "height": size[1]}
    note = f"Screenshot of {t.name} ({output or 'all outputs'}): {size[0]}x{size[1]} px."
    if name == "workspace" and not t.windows():
        note += (
            " The workspace is empty. To see what the user has open, take a "
            'screenshot with target "desktop"; to work here, use launch_app.'
        )
    return [
        {"type": "image", "data": base64.b64encode(png).decode(), "mimeType": "image/png"},
        {"type": "text", "text": note},
    ]


def list_outputs(target=None):
    return json.dumps(_target(target)[1].outputs(), indent=2)


def move_mouse(x, y, target=None):
    name, t = _target(target)
    t.move(*_to_global(name, x, y))
    return f"Moved to ({x}, {y})."


def click(x, y, button="left", count=1, target=None):
    if button not in ("left", "right", "middle"):
        raise ValueError("button must be left, right or middle")
    name, t = _target(target)
    t.move(*_to_global(name, x, y))
    count = max(1, min(count, 3))
    for _ in range(count):
        t.button(button, True)
        t.button(button, False)
        time.sleep(0.05)
    return f"{button.capitalize()}-clicked {count}x at ({x}, {y})."


def drag(start_x, start_y, end_x, end_y, target=None):
    name, t = _target(target)
    sx, sy = _to_global(name, start_x, start_y)
    ex, ey = _to_global(name, end_x, end_y)
    t.move(sx, sy)
    t.button("left", True)
    steps = 20
    for i in range(1, steps + 1):
        t.move(sx + (ex - sx) * i / steps, sy + (ey - sy) * i / steps)
    t.button("left", False)
    return f"Dragged ({start_x}, {start_y}) -> ({end_x}, {end_y})."


def scroll(x, y, direction="down", amount=3, target=None):
    if direction not in ("up", "down", "left", "right"):
        raise ValueError("direction must be up, down, left or right")
    name, t = _target(target)
    t.move(*_to_global(name, x, y))
    n = max(1, min(amount, 20))
    t.wheel(direction, n)
    return f"Scrolled {direction} {n} at ({x}, {y})."


def type_text(text, target=None):
    _run("wtype", "-d", "5", "-", input=text.encode(), env=_target(target)[1].env())
    return f"Typed {len(text)} characters."


MODIFIERS = {
    "ctrl": "ctrl", "control": "ctrl", "shift": "shift", "alt": "alt",
    "super": "logo", "meta": "logo", "win": "logo", "cmd": "logo", "logo": "logo",
    "altgr": "altgr",
}
KEY_ALIASES = {
    "enter": "Return", "return": "Return", "esc": "Escape", "escape": "Escape",
    "tab": "Tab", "backspace": "BackSpace", "delete": "Delete", "del": "Delete",
    "space": "space", "up": "Up", "down": "Down", "left": "Left", "right": "Right",
    "home": "Home", "end": "End", "pageup": "Page_Up", "pagedown": "Page_Down",
    "insert": "Insert", "menu": "Menu",
}


def key(keys, target=None):
    *mods, name = [p.strip() for p in keys.split("+")]
    args = []
    for m in mods:
        if m.lower() not in MODIFIERS:
            raise ValueError(f"Unknown modifier {m!r}")
        args += ["-M", MODIFIERS[m.lower()]]
    args += ["-k", KEY_ALIASES.get(name.lower(), name)]
    for m in reversed(mods):
        args += ["-m", MODIFIERS[m.lower()]]
    _run("wtype", *args, env=_target(target)[1].env())
    return f"Pressed {keys}."


def list_windows(target=None):
    return json.dumps(_target(target)[1].windows(), indent=2)


def focus_window(window_id, target=None):
    _target(target)[1].focus(window_id)
    return f"Focused window {window_id}."


def launch_app(command, target=None):
    _target(target)[1].launch(command)
    return f"Launched: {command}"


TARGET = {
    "type": "string",
    "enum": ["desktop", "workspace"],
    "description": "desktop (default): the user's screen and all its windows. "
    "workspace: a separate nested session, only when asked.",
}


def _schema(required=(), **props):
    props["target"] = TARGET
    return {"type": "object", "properties": props, "required": list(required)}


INT = {"type": "integer"}
XY = {"x": INT, "y": INT}

# name: (handler, description, input schema)
TOOLS = {
    "screenshot": (
        screenshot,
        "Capture the screen of the target. To see what the user has open "
        '(their windows, browser tabs, documents), use target "desktop". '
        "Coordinates for click, move_mouse, drag and "
        "scroll are pixels in the most recent screenshot, so take a new one "
        "after the screen changes. By default all outputs are captured; pass an "
        "output name from list_outputs to capture one at higher detail.",
        _schema(output={"type": "string"}, show_cursor={"type": "boolean"}),
    ),
    "list_outputs": (
        list_outputs,
        "List outputs with their position and size in the layout.",
        _schema(),
    ),
    "move_mouse": (
        move_mouse,
        "Move the pointer to (x, y) in the last screenshot.",
        _schema(("x", "y"), **XY),
    ),
    "click": (
        click,
        "Click at (x, y) in the last screenshot. count=2 double-clicks.",
        _schema(
            ("x", "y"),
            **XY,
            button={"type": "string", "enum": ["left", "right", "middle"]},
            count=INT,
        ),
    ),
    "drag": (
        drag,
        "Drag with the left button from the start to the end point "
        "(coordinates in the last screenshot).",
        _schema(
            ("start_x", "start_y", "end_x", "end_y"),
            start_x=INT, start_y=INT, end_x=INT, end_y=INT,
        ),
    ),
    "scroll": (
        scroll,
        "Scroll at (x, y) in the last screenshot by amount wheel notches.",
        _schema(
            ("x", "y"),
            **XY,
            direction={"type": "string", "enum": ["up", "down", "left", "right"]},
            amount=INT,
        ),
    ),
    "type_text": (
        type_text,
        "Type text into the focused window (any Unicode). Use key for "
        "shortcuts and special keys.",
        _schema(("text",), text={"type": "string"}),
    ),
    "key": (
        key,
        'Press a key or shortcut in the focused window, e.g. "Return", '
        '"ctrl+c", "ctrl+shift+t", "alt+F4". Names are XKB keysyms '
        "(F1-F12, Up, Page_Down, ...); aliases like enter/esc work too.",
        _schema(("keys",), keys={"type": "string"}),
    ),
    "list_windows": (
        list_windows,
        "List open windows on the target (id, app id, title, focus).",
        _schema(),
    ),
    "focus_window": (
        focus_window,
        "Focus a window by id from list_windows.",
        _schema(("window_id",), window_id=INT),
    ),
    "launch_app": (
        launch_app,
        "Start a program on the target with a shell command, e.g. "
        '"foot" or "claude-workspace-browser https://example.com" (a '
        "separate browser profile, so it opens here rather than in the "
        "user's own browser).",
        _schema(("command",), command={"type": "string"}),
    ),
}


INSTRUCTIONS = (
    "These tools control the user's whole desktop: every window on every "
    'monitor. target "workspace" is a separate nested session, used only '
    "when asked."
)


def _call_tool(params):
    name = params.get("name")
    if name not in TOOLS:
        raise ValueError(f"Unknown tool {name!r}")
    try:
        result = TOOLS[name][0](**(params.get("arguments") or {}))
    except Exception as e:
        return {"content": [{"type": "text", "text": f"Error: {e}"}], "isError": True}
    if isinstance(result, str):
        result = [{"type": "text", "text": result}]
    return {"content": result, "isError": False}


def _handle(method, params):
    if method == "initialize":
        return {
            "protocolVersion": params.get("protocolVersion", "2025-06-18"),
            "capabilities": {"tools": {}},
            "serverInfo": {"name": "desktop-control", "version": "1.2"},
            "instructions": INSTRUCTIONS,
        }
    if method == "ping":
        return {}
    if method == "tools/list":
        return {
            "tools": [
                {"name": n, "description": d, "inputSchema": s}
                for n, (_, d, s) in TOOLS.items()
            ]
        }
    if method == "tools/call":
        return _call_tool(params)
    raise LookupError(method)


def main():
    _discover_session_env()
    for line in sys.stdin:
        if not line.strip():
            continue
        msg = json.loads(line)
        if "id" not in msg:
            continue  # Notifications need no reply.
        reply = {"jsonrpc": "2.0", "id": msg["id"]}
        try:
            reply["result"] = _handle(msg.get("method"), msg.get("params") or {})
        except LookupError:
            reply["error"] = {"code": -32601, "message": f"Method not found: {msg.get('method')}"}
        except Exception as e:
            reply["error"] = {"code": -32603, "message": str(e)}
        sys.stdout.write(json.dumps(reply) + "\n")
        sys.stdout.flush()


if __name__ == "__main__":
    main()

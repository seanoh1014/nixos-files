#!/bin/sh
set -eu

# Node's recursive copy preserves the Nix store's read-only modes. ChatGPT
# edits a few copied plugin manifests at startup, so keep that bundled plugin
# tree in a small, versioned, writable cache. The resources override also has
# to expose the bundled Codex and Node runtimes used by the Chrome bridge.
cache_root=${XDG_CACHE_HOME:-${HOME:?HOME is required}/.cache}/chatgpt-nix/@version@
plugin_resources="$cache_root/resources"

if [ ! -e "$plugin_resources/.ready" ]; then
  @coreutils@/bin/mkdir -p "$cache_root"
  staging=$(@coreutils@/bin/mktemp -d "$cache_root/.resources.XXXXXX")

  cleanup() {
    trap - 0 1 2 15
    @coreutils@/bin/chmod -R u+w "$staging" 2>/dev/null || true
    @coreutils@/bin/rm -rf -- "$staging"
  }
  trap cleanup 0 1 2 15

  @coreutils@/bin/mkdir -p "$staging/plugins"
  @coreutils@/bin/cp -R @pluginSource@ "$staging/plugins/openai-bundled"
  @coreutils@/bin/chmod -R u+w "$staging"
  : > "$staging/.ready"

  if @coreutils@/bin/mv -T "$staging" "$plugin_resources" 2>/dev/null; then
    trap - 0 1 2 15
  else
    cleanup
    if [ ! -e "$plugin_resources/.ready" ]; then
      echo "chatgpt: could not prepare its writable plugin cache" >&2
      exit 1
    fi
  fi
fi

# The environment variable below replaces the app's complete resources path,
# not only its plugin path. Keep the large, immutable runtimes in the Nix store
# and expose them through links in the writable resource overlay. Refresh the
# links on every launch so rebuilding the same upstream version cannot leave
# stale Nix store targets behind.
for runtime_entry in codex codex-code-mode-host cua_node; do
  @coreutils@/bin/ln -sfnT \
    "@resourcesSource@/$runtime_entry" \
    "$plugin_resources/$runtime_entry"
done

export CODEX_ELECTRON_BUNDLED_PLUGINS_RESOURCES_PATH="$plugin_resources"
export ELECTRON_TRASH=gio
export PATH="@runtimePath@${PATH:+:$PATH}"
export LD_LIBRARY_PATH="@runtimeLibraries@${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

exec @chatgptExecutable@ "$@"

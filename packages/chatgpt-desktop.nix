{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  coreutils,
  dpkg,
  addDriverRunpath,
  alsa-lib,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  git,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libglvnd,
  libnotify,
  libpulseaudio,
  libsecret,
  libusb1,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  nspr,
  nss,
  pango,
  systemdLibs,
  wayland,
  xdg-utils,
}:

let
  runtimeLibraries = [
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libgbm
    libglvnd
    libnotify
    libpulseaudio
    libsecret
    libusb1
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    systemdLibs
    wayland
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "chatgpt-desktop";
  version = "26.908.70816";

  src = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${finalAttrs.version}_amd64.deb";
    hash = "sha256-EO0MGogLmXXR8YW/eRGn9RTga5hjzU7ZVh1ABjYXyFQ=";
  };

  strictDeps = true;
  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = runtimeLibraries;

  # These are optional Ubuntu desktop-integration shims and unused musl
  # prebuilds. The application itself does not require them on NixOS.
  autoPatchelfIgnoreMissingDeps = [
    "libQt5Core.so.5"
    "libQt5Gui.so.5"
    "libQt5Widgets.so.5"
    "libQt6Core.so.6"
    "libQt6Gui.so.6"
    "libQt6Widgets.so.6"
    "libc.musl-x86_64.so.1"
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib" "$out/bin" "$out/share/applications" "$out/share/pixmaps"
    cp -a usr/lib/chatgpt "$out/lib/"
    cp -a usr/share/applications/chatgpt.desktop "$out/share/applications/"
    cp -a usr/share/pixmaps/chatgpt.png "$out/share/pixmaps/"

    substitute ${./chatgpt-wrapper.sh} "$out/bin/chatgpt" \
      --subst-var-by chatgptExecutable "$out/lib/chatgpt/ChatGPT" \
      --subst-var-by coreutils ${coreutils} \
      --subst-var-by pluginSource "$out/lib/chatgpt/resources/plugins/openai-bundled" \
      --subst-var-by resourcesSource "$out/lib/chatgpt/resources" \
      --subst-var-by runtimeLibraries "${addDriverRunpath.driverLink}/lib:${lib.makeLibraryPath runtimeLibraries}" \
      --subst-var-by runtimePath ${lib.makeBinPath [ git glib xdg-utils ]} \
      --subst-var-by version ${finalAttrs.version}
    chmod +x "$out/bin/chatgpt"

    runHook postInstall
  '';

  meta = {
    description = "Official ChatGPT desktop app for Linux, including Codex";
    homepage = "https://learn.chatgpt.com/docs/linux/linux-app";
    license = lib.licenses.unfree;
    mainProgram = "chatgpt";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})

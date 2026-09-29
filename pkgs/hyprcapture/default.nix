{
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  glib,
  lua,
  nlohmann_json,
  kdePackages,
  hyprlandPlugins,
}:
# Tag pinned to the Hyprland release it targets (0.55.4); bump both together.
hyprlandPlugins.mkHyprlandPlugin {
  pluginName = "hyprcapture";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "gfhdhytghd";
    repo = "HyprCapture";
    rev = "v0.2.4-0.55.4";
    hash = "sha256-KoPr8KykCeyCoFzg25PEMtZRIJxcpfdwk/uL//Wt6lc=";
  };

  # Backport of upstream 15a831a (in releases for Hyprland 0.56+): the trust
  # checks reject anything under the group-writable /nix/store, and the helper
  # only looks for wl-copy/hyprctl/xdg-open in /usr/bin (without wl-copy the
  # clipboard dies with it). Patch also searches the Nix profile bin dirs.
  patches = [ ./trust-nix-store.patch ];

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    glib
    lua
    nlohmann_json
    kdePackages.qtbase
    kdePackages.qtsvg
    kdePackages.layer-shell-qt
  ];

  meta = {
    homepage = "https://github.com/gfhdhytghd/HyprCapture";
    description = "Hyprland screenshot overlay plugin";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}

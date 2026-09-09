{ pkgs, config, ... }:
let
  wrapGL = config.lib.nixGL.wrap;
in
{
  home.packages = with pkgs; [
    (wrapGL waybar)
    fuzzel
    mako
    libnotify
    (wrapGL waypaper)
    swww

    # Vim anywhere (Wayland)
    wofi
    wtype
  ];
}

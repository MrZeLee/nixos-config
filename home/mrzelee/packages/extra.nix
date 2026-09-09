{
  pkgs,
  lib,
  inputs,
  system,
  isLinux,
  isX86_64,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      # AI
      unstable.codex
      unstable.opencode

      # Media
      master.spotify-player

      # ios
      usbmuxd
      inputs.iloader.packages.${system}.default
    ]
    ++ lib.optionals isLinux [
      # Security
      tor
      torsocks
      seahorse
      monero-cli
      monero-gui
      onionshare-gui

      # Misc
      qbittorrent
      gnucash
      kdePackages.okular

      # File management
      nemo-with-extensions
      gvfs
      udisks2
      gphoto2
      libmtp
      cinnamon-desktop
      shared-mime-info
      xdg-utils

      # Wayland / theme
      swaybg
      catppuccin-sddm
    ]
    ++ lib.optionals (isLinux && isX86_64) [
      tor-browser
    ];
}

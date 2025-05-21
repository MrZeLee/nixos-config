{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs;
    [
      # Security
      keepassxc
      gnupg
      pass
      tor
      torsocks

      # System
      pciutils

      # Network
      nmap
      netcat
      wget
      curl
      teleport_17

      # Misc
      qbittorrent
      # mmex
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      #Security
      tor-browser
      seahorse
      monero-cli
      monero-gui

      #System
      usbutils
      lshw

      #Misc
      gnucash
      vdhcoapp
      libreoffice

      #Media
      stremio

      #Network
      sshfs
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
    ];
}

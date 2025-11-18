{
  pkgs,
  lib,
  isLinux,
  isDarwin,
  isX86_64,
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
      ghostscript
      pdfpc
    ]
    ++ lib.optionals isLinux [
      #Security
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
      kdePackages.okular

      #Media
      stremio
      bluetui

      #Network
      sshfs

      #Lightweight terminal
      enlightenment.terminology
    ]
    ++ lib.optionals (isLinux && isX86_64) [
      tor-browser
    ]
    ++ lib.optionals isDarwin [
    ];
}

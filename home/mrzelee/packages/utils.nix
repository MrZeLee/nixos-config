{
  pkgs,
  lib,
  isLinux,
  isDarwin,
  isX86_64,
  ...
}:
{
  home.packages =
    with pkgs;
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
      obsidian
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
      (ledger.override {
        # gpgmeSupport dropped in 26.05: gpgme 2.0 split out gpgmepp, and
        # ledger's find_package(Gpgmepp 1.13.1) no longer resolves.
        usePython = true;
      })
      libreoffice
      kdePackages.okular

      #Media
      #stremio
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

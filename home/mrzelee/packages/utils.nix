{pkgs, ...}: {
  home.packages = with pkgs;
    [
      # Security
      keepassxc
      gnupg
      pass
      tor

      # System
      pciutils

      # Network
      nmap
      netcat
      wget
      curl

      # Misc
      qbittorrent
      mmex
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      #Security
      tor-browser
      pinentry-all
      seahorse

      #System
      usbutils
      lshw
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      pinentry_mac
    ];
}

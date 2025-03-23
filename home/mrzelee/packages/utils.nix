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

      # System
      pciutils

      # Network
      nmap
      netcat
      wget
      curl

      # Misc
      qbittorrent
      # mmex
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      #Security
      tor-browser
      seahorse

      #System
      usbutils
      lshw

      #Misc
      gnucash
      vdhcoapp
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
    ];
}

{
  pkgs,
  lib,
  config,
  isLinux,
  isDarwin,
  ...
}:
let
  wrapGL = config.lib.nixGL.wrap;
in
{
  home.packages =
    with pkgs;
    [
      # Security
      (wrapGL keepassxc)
      gnupg
      pass
      age

      # System
      pciutils

      # Network
      nmap
      netcat
      wget
      curl
      teleport_17

      # Misc
      (wrapGL obsidian)
      ghostscript
      (wrapGL pdfpc)
    ]
    ++ lib.optionals isLinux [
      #System
      usbutils
      lshw

      #Misc
      (ledger.override {
        # gpgmeSupport dropped in 26.05: gpgme 2.0 split out gpgmepp, and
        # ledger's find_package(Gpgmepp 1.13.1) no longer resolves.
        usePython = true;
      })
      (wrapGL libreoffice)

      #Media
      bluetui

      #Network
      sshfs

      #Lightweight terminal
      (wrapGL enlightenment.terminology)
    ]
    ++ lib.optionals isDarwin [
    ];
}

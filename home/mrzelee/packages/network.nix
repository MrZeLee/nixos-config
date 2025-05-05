{pkgs, ...}: {
  home.packages = with pkgs;
    [
      # TODO: set this up to work
      # zerotierone
      wireshark
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      onionshare-gui
    ];
}

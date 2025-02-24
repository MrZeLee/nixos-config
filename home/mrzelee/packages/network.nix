{pkgs, ...}: {
  home.packages = with pkgs;
    [
      zerotierone
      wireshark
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      onionshare-gui
    ];
}

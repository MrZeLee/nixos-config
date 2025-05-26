{pkgs, isLinux, ...}: {
  home.packages = with pkgs;
    [
      # TODO: set this up to work
      # zerotierone
      wireshark
    ]
    ++ lib.optionals isLinux [
      onionshare-gui
    ];
}

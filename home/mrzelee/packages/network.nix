{pkgs, isLinux, ...}: {
  home.packages = with pkgs;
    [
      # TODO: set this up to work
      # zerotierone
      wireshark
      openvpn
      wireguard-tools
    ]
    ++ lib.optionals isLinux [
      onionshare-gui
    ];
}

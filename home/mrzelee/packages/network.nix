{ pkgs, isLinux, ... }:
{
  home.packages =
    with pkgs;
    [
      # TODO: set this up to work
      # zerotierone
      wireshark
      dnsutils
      openvpn
      wireguard-tools
    ]
    ++ lib.optionals isLinux [
      onionshare-gui
    ];
}

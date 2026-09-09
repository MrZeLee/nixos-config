{ pkgs, config, ... }:
let
  wrapGL = config.lib.nixGL.wrap;
in
{
  home.packages = with pkgs; [
    # TODO: set this up to work
    # zerotierone
    (wrapGL wireshark)
    dnsutils
    openvpn
    wireguard-tools
  ];
}

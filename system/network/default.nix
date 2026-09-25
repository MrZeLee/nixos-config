{
  lib,
  pkgs,
  ...
}:
{
  # Enable networking
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
  };
  networking.nameservers = [
    "8.8.8.8"
    "1.1.1.1"
  ];
  networking.extraHosts = "127.0.0.1 azurite";
  # Note: to connect to wifi use command nmcli device wifi connect <SSID> password
  # <password>

  services = {
    # DNS resolver
    resolved.enable = true;
    # avahi already owns mDNS here (CUPS, Sunshine). With resolved answering
    # for <host>.local too, avahi sees its own name taken and renames itself
    # every 20s (desktop-1, -2, ...), which tears down every published
    # service -- Moonlight then never discovers Sunshine.
    resolved.settings.Resolve.MulticastDNS = false;
  };

  # Don't wait for network startup
  systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart = [
    ""
    "${pkgs.networkmanager}/bin/nm-online -q"
  ];

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
    dnsmasq
  ];

  imports = [
    ./iperf3.nix
    ./spotify.nix
    ./openvpn3.nix
  ];
}

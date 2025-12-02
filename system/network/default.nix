{
  lib,
  pkgs,
  ...
}: {
  # Enable networking
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
  };
  networking.nameservers = ["8.8.8.8" "1.1.1.1"];
  networking.extraHosts = "127.0.0.1 azurite";
  # Note: to connect to wifi use command nmcli device wifi connect <SSID> password
  # <password>

  services = {
    # DNS resolver
    resolved.enable = true;
  };

  # Don't wait for network startup
  systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart = ["" "${pkgs.networkmanager}/bin/nm-online -q"];

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

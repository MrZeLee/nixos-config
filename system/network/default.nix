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

  services = {
    # DNS resolver
    resolved.enable = true;
  };

  # Don't wait for network startup
  systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart = ["" "${pkgs.networkmanager}/bin/nm-online -q"];

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];
}

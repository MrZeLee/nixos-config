{pkgs, ...}: {
  networking.firewall.allowedTCPPorts = [ 5201 ];

  environment.systemPackages = with pkgs; [
    iperf3
  ];

}

{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ../../../system
  ];

  networking.hostName = "desktop";
  system.stateVersion = "24.11"; # Add this line

  # Desktop-specific configurations

  # Enable NVIDIA drivers
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    prime = {
      sync.enable = true;

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  hardware.cpu.intel.sgx.provision.enable = true;
}

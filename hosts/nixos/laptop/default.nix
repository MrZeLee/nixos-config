{
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ../../../system
  ];

  networking.hostName = "laptop";
  system.stateVersion = "24.11";

  # Enable NVIDIA drivers
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    prime = {
      sync.enable = true;

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

}

{
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    # ./apple-silicon-support
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
    ../../../system
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  #Specify path to peripheral firmware files.
  hardware.asahi.peripheralFirmwareDirectory = ./firmware;

  # For ` to < and ~ to > (for those with US keyboards)
  boot.extraModprobeConfig = ''
    options hid_apple iso_layout=0
  '';

  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  networking.hostName = "macbook-nixos"; # Define your hostname.

  system.stateVersion = "25.11"; # Did you read the comment?

  services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];

  environment.systemPackages = with pkgs; [
    displaylink
  ];
}

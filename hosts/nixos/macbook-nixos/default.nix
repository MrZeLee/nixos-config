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
  hardware.asahi.withRust = true;
  hardware.asahi.useExperimentalGPUDriver = true;

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

  services.xserver.videoDrivers = lib.mkForce [];

  # # configuration.nix:
  # boot.kernelParams = [ "button.lid_init_state=open" ];
  # powerManagement.enable = true;
  # powerManagement.resumeCommands = "sudo ${pkgs.kmod}/bin/rmmod atkbd; sudo ${pkgs.kmod}/bin/modprobe atkbd reset=1";
  #
  # services.logind.extraConfig = ''
  #    HandlePowerKey=suspend-then-hibernate
  #    HandlePowerKeyLongPress=poweroff
  #    HandleLidSwitch=suspend-then-hibernate
  #    HandleLidSwitchExternalPower=suspend-then-hibernate
  #    HandleLidSwitchDocked=suspend-then-hibernate
  #    HoldoffTimeoutSec=5s
  #    IdleAction=suspend
  #    IdleActionSec=300s
  #  '';
  #
  #  systemd.services.disable-nvme-d3cold = {
  #    enable = true;
  #    description = "Disable d3cold for NVMe to fix suspend issues";
  #    wantedBy = [ "multi-user.target" ];
  #    after = [ "network.target" ];
  #    serviceConfig = {
  #      Type = "oneshot";
  #      ExecStart = "${pkgs.coreutils}/bin/echo 0 > /sys/bus/pci/devices/0000:01:00.0/d3cold_allowed";
  #      RemainAfterExit = true;
  #    };
  #  };
  #
  #  services.logind = {
  #    lidSwitch = "suspend";
  #  };
  #
  #  # Macbook pro fan controlls is an option too.
  #  services.mbpfan = {
  #    enable = true;
  #    aggressive = false;
  #    settings.general = { # even more agressive settings for the fan
  #        low_temp = 50;
  #        high_temp = 55;
  #        max_temp = 65;
  #    };
  #  };

  # environment.systemPackages = with pkgs; [
  #   displaylink
  # ];
}

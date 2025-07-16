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
    ./boot.nix
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
  
  # Hibernation support: suspend-to-disk via initrd resume hook
  swapDevices = lib.mkForce [ { device = "/swapfile"; size = 16384; } ];
  boot.resumeDevice = lib.mkForce "/swapfile";

  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  networking.hostName = "macbook-nixos"; # Define your hostname.

  system.stateVersion = "25.11"; # Did you read the comment?

  services.xserver.videoDrivers = lib.mkForce [];

  # Kernel parameters: resume support, ACPI tweaks, lid init state,
  # and force Apple-specific cpuidle driver (WFI/WFE hack) over PSCI
  boot.kernelParams = lib.mkForce [
    "resume=/swapfile"
    "acpi_osi=Linux"
    "acpi_backlight=video"
    "button.lid_init_state=open"
    # Use the Apple cpuidle driver for proper WFI/WFE idle on Apple Silicon
    "cpuidle.driver=apple"
  ];
  powerManagement.enable = lib.mkForce true;
  powerManagement.resumeCommands = "sudo ${pkgs.kmod}/bin/rmmod atkbd; sudo ${pkgs.kmod}/bin/modprobe atkbd reset=1";

  services.logind.extraConfig = ''
     HandlePowerKey=suspend-then-hibernate
     HandlePowerKeyLongPress=poweroff
     HandleLidSwitch=suspend-then-hibernate
     HandleLidSwitchExternalPower=suspend-then-hibernate
     HandleLidSwitchDocked=suspend-then-hibernate
     HoldoffTimeoutSec=5s
     IdleAction=suspend
     IdleActionSec=300s
     HibernateDelaySec=10min
   '';

   systemd.services.disable-nvme-d3cold = {
     enable = true;
     description = "Disable d3cold for NVMe to fix suspend issues";
     wantedBy = [ "multi-user.target" ];
     after = [ "network.target" ];
     serviceConfig = {
       Type = "oneshot";
       ExecStart = "${pkgs.coreutils}/bin/echo 0 > /sys/bus/pci/devices/0000:01:00.0/d3cold_allowed";
       RemainAfterExit = true;
     };
   };


   # # Macbook pro fan controlls is an option too.
   # services.mbpfan = {
   #   enable = true;
   #   aggressive = false;
   #   settings.general = { # even more agressive settings for the fan
   #       low_temp = 50;
   #       high_temp = 55;
   #       max_temp = 65;
   #   };
   # };

  services.power-profiles-daemon = {
    enable     = true;
  };


  # install the default config with our on-ac / on-battery settings
  environment.etc."power-profiles-daemon/config.toml".text = lib.trim ''
    [general]
    # which profile to pick at boot if none is active
    default-profile = "balanced"

    # switch profiles on AC / battery insert/remove
    on-ac      = "performance"
    on-battery = "powersave"

    # how long to wait after an AC/BAT event before switching
    timeout = 10

    # If you want to tweak the individual profiles, you can do so here:
    #
    #[profile.powersave]
    #  # example: turn on schedutil governor
    #  governor = "schedutil"
    #
    #[profile.performance]
    #  governor = "performance"
  '';

  environment.systemPackages = with pkgs; [
    brightnessctl
    playerctl
    # displaylink
  ];
}

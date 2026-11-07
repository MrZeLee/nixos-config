{
  lib,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    # ./apple-silicon-support
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
    ../../../system
    ./boot.nix
  ];

  hardware.asahi.enable = true;
  #Specify path to peripheral firmware files.
  hardware.asahi.peripheralFirmwareDirectory = ./firmware;

  services.pipewire.lowLatency.enable = lib.mkForce false;

  # Use iwd as NetworkManager's wifi backend (more stable on M1)
  networking.wireless.iwd = {
    enable = true;
    settings = {
      General = {
        EnableNetworkConfiguration = true;
        # allow a longer assoc timeout for flaky links
        AssociateTimeout = 30;
      };
    };
  };

  networking.networkmanager.wifi = {
    # delegate all wifi to iwd
    backend = "iwd";
  };

  networking.hostName = "macbook-nixos"; # Define your hostname.

  system.stateVersion = "25.11"; # Did you read the comment?

  # DisplayLink: video out of the UGREEN CM558 dock (evdi + DisplayLinkManager)
  services.xserver.videoDrivers = lib.mkForce [ "displaylink" ];

  powerManagement.enable = lib.mkForce true;
  powerManagement.resumeCommands = "sudo ${pkgs.kmod}/bin/rmmod atkbd; sudo ${pkgs.kmod}/bin/modprobe atkbd reset=1";

  services.logind.settings.Login = {
    HandlePowerKey = "suspend-then-hibernate";
    HandlePowerKeyLongPress = "poweroff";
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "ignore";
    HoldoffTimeoutSec = "5s";
    IdleAction = "suspend";
    IdleActionSec = "300s";
    HibernateDelaySec = "10min";
  };

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

  # Fix DRM/GPU race condition on Apple Silicon - ensure display-manager
  # waits for GPU and DRM devices to be fully initialized before starting
  systemd.services.display-manager = {
    after = [
      "systemd-udev-settle.service"
      "plymouth-quit.service"
    ];
    wants = [ "systemd-udev-settle.service" ];
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
    enable = true;
  };

  # ppd has no on-ac/on-battery config; switch profiles from udev instead
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", KERNEL=="macsmc-ac", ATTR{online}=="0", RUN+="${lib.getExe pkgs.power-profiles-daemon} set power-saver"
    SUBSYSTEM=="power_supply", KERNEL=="macsmc-ac", ATTR{online}=="1", RUN+="${lib.getExe pkgs.power-profiles-daemon} set balanced"
  '';

  # udev's boot-time event fires before ppd is up, so apply once after it starts
  systemd.services.ppd-ac-sync = {
    wantedBy = [ "multi-user.target" ];
    after = [ "power-profiles-daemon.service" ];
    requires = [ "power-profiles-daemon.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      if [ "$(cat /sys/class/power_supply/macsmc-ac/online)" = 1 ]; then p=balanced; else p=power-saver; fi
      ${lib.getExe pkgs.power-profiles-daemon} set $p
    '';
  };

  # warp-svc keeps waking the CPU/radio; tailscale covers remote access here
  services.cloudflare-warp.enable = lib.mkForce false;

  environment.systemPackages = with pkgs; [
    brightnessctl
    playerctl
  ];
}

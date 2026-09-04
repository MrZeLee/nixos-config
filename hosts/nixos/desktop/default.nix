{
  config,
  pkgs,
  ...
}:
let
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  jq = "${pkgs.jq}/bin/jq";

  # ponytail: acts on the focused monitor -- correct while Sunshine captures the
  # only/primary output. Pin a name here if you ever stream one monitor while
  # working on another.
  sunshineMode = pkgs.writeShellScript "sunshine-mode" ''
    set -eu
    mon=$(${hyprctl} monitors -j | ${jq} -r 'first(.[] | select(.focused))
          | "\(.name),\(.x)x\(.y)"')
    name=''${mon%%,*}
    pos=''${mon#*,}

    case "$1" in
      do)
        ${hyprctl} keyword monitor \
          "$name,''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS},$pos,1"
        ;;
      undo)
        # re-reading hyprland.conf restores the modes declared there
        ${hyprctl} reload
        ;;
    esac
  '';
in
{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ../../../system
  ];

  networking.hostName = "desktop";
  system.stateVersion = "24.11"; # Add this line

  # Desktop-specific configurations

  # Enable NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    prime = {
      sync.enable = true;

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Game stream host for Moonlight clients (htpc, laptop)
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true; # DRM/KMS capture under Wayland

    # Match the mode Moonlight asks for on connect, restore it on disconnect.
    # global_prep_cmd applies to every app, including Sunshine's built-in Desktop.
    settings.global_prep_cmd = builtins.toJSON [
      {
        do = "${sunshineMode} do";
        undo = "${sunshineMode} undo";
        elevated = "false";
      }
    ];
  };

  hardware.cpu.intel.sgx.provision.enable = true;
  environment.systemPackages = [ pkgs.grub2 ];
}

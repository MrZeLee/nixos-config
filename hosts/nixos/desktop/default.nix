{
  config,
  lib,
  pkgs,
  ...
}:
let
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  jq = "${pkgs.jq}/bin/jq";

  # Virtual output streamed to Moonlight, so the physical monitors are left
  # alone. Named explicitly: a bare `output create headless` yields HEADLESS-2,
  # -3, -4... on each call, which a static output_name in sunshine.conf cannot
  # follow.
  sunshineDisplay = pkgs.writeShellScript "sunshine-display" ''
    set -u
    case "$1" in
      do)
        # a crashed stream can leave the output behind -- reuse it
        ${hyprctl} output create headless stream || true
        ${hyprctl} keyword monitor \
          "stream,''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS},auto,1"
        # so apps launched during the stream open on it
        ${hyprctl} dispatch focusmonitor stream
        ;;
      undo)
        real=$(${hyprctl} monitors -j | ${jq} -r 'first(.[] | select(.name != "stream")).name')
        ${hyprctl} dispatch focusmonitor "$real"
        ${hyprctl} output remove stream
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

    # Without CUDA, Sunshine builds with SUNSHINE_ENABLE_CUDA=FALSE and NVENC
    # dies at the colour-conversion step ("Couldn't scale frame"), leaving only
    # software x264. The stock cudaSupport postFixup --set LD_LIBRARY_PATH to
    # just vulkan-loader, which hides the driver's libcuda.so.1; --prefix with
    # the driver path added keeps both reachable.
    package =
      (pkgs.sunshine.override {
        cudaSupport = true;
        inherit (pkgs) cudaPackages;
      }).overrideAttrs
        (_: {
          postFixup = ''
            wrapProgram $out/bin/sunshine \
              --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ pkgs.vulkan-loader ]}:/run/opengl-driver/lib"
          '';
        });

    settings = {
      # wlr screencopy rather than kmsgrab: only it can see a virtual output.
      # It also needs no CAP_SYS_ADMIN, so capSysAdmin stays off.
      capture = "wlr";
      output_name = "stream";

      # Size the virtual output to what the client asks for, tear it down after.
      global_prep_cmd = builtins.toJSON [
        {
          do = "${sunshineDisplay} do";
          undo = "${sunshineDisplay} undo";
          elevated = "false";
        }
      ];
    };
  };

  # Wake-on-LAN from S5: a cold boot has to reach a running Hyprland session
  # for Sunshine to have anything to capture, so SDDM logs in automatically.
  networking.interfaces.enp2s0.wakeOnLan.enable = true;

  # Host-only, deliberately: system/services/sddm.nix is shared by every NixOS
  # host and none of the others should autologin.
  services.displayManager.autoLogin = {
    enable = true;
    user = "mrzelee";
  };

  # sddm-autologin's PAM stack is nologin + succeed_if + permit, so no password
  # ever reaches pam_gnome_keyring and the login keyring would stay locked.
  # Unlocking hyprlock supplies it instead.
  security.pam.services.hyprlock.enableGnomeKeyring = true;

  hardware.cpu.intel.sgx.provision.enable = true;
  environment.systemPackages = [ pkgs.grub2 ];
}

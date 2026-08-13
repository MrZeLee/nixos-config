{ lib, pkgs, ... }:
let
  kodi = pkgs.kodi-gbm.withPackages (kp: [
    kp.jellyfin
    kp.joystick # peripheral.joystick — required for gamepad input
    kp.pvr-iptvsimple # live TV from an M3U playlist (EPG via XMLTV)
    (kp.buildKodiAddon {
      pname = "moonlight-launcher";
      namespace = "script.moonlight-launcher";
      version = "1.0.0";
      src = ./kodi-moonlight-addon;
    })
    (kp.buildKodiAddon {
      pname = "tailscale-toggle";
      namespace = "script.tailscale-toggle";
      version = "1.0.0";
      src = ./kodi-tailscale-addon;
    })
  ]);

  # Session loop: Kodi owns the screen; the Moonlight addon drops a flag
  # file and quits Kodi, we run moonlight-qt on KMS, then Kodi comes back.
  htpc-session = pkgs.writeShellScriptBin "htpc-session" ''
    flag="$XDG_RUNTIME_DIR/launch-moonlight"
    while true; do
      rm -f "$flag"
      ${kodi}/bin/kodi
      if [ -e "$flag" ]; then
        QT_QPA_PLATFORM=eglfs ${lib.getExe pkgs.moonlight-qt}
      fi
    done
  '';
in
{
  imports = [
    ./hardware-configuration.nix
    ../../../system/services/tailscale.nix
  ];

  # The Kodi addon drives the tailscale CLI. Operator mode can't cover
  # login: logout wipes OperatorUser from the profile, and getting it
  # back needs root. So: sudo for exactly this one binary.
  security.sudo.extraRules = [
    {
      users = [ "htpc" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/tailscale";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # QR rendering for the tailscale addon's login flow.
  environment.systemPackages = [ pkgs.qrencode ];

  # Kodi remote control (Kore app / web UI) + EventServer.
  networking.firewall.allowedTCPPorts = [ 8080 ];
  networking.firewall.allowedUDPPorts = [ 9777 ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "htpc";

  hardware.enableRedistributableFirmware = true;

  # Mesa: RADV for Vulkan, radeonsi VAAPI for Kodi/Moonlight. No amdvlk.
  hardware.graphics.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  users.mutableUsers = false;

  users.users.htpc = {
    isNormalUser = true;
    extraGroups = [
      "video"
      "render"
      "input"
      "dialout" # Pulse-Eight USB-CEC adapter (ttyACM)
    ];
  };

  users.users.mrzelee = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxGPJr0yZ9d+SOYqmEBP2GPejrfbAc45Ijsvk3PWYEP mrzelee404@gmail.com"
    ];
  };

  # No passwords exist (mutableUsers = false, key-only SSH), so wheel
  # must sudo without one — also what remote nixos-rebuild --sudo needs.
  security.sudo.wheelNeedsPassword = false;

  # Autologin straight into the Kodi/Moonlight session loop on tty1.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${htpc-session}/bin/htpc-session";
      user = "htpc";
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # First install of this box; do not bump on upgrades.
  system.stateVersion = "26.05";
}

{ pkgs, ... }:
let
  kodi = pkgs.kodi-gbm.withPackages (kp: [
    kp.jellyfin
    (kp.buildKodiAddon {
      pname = "moonlight-launcher";
      namespace = "script.moonlight-launcher";
      version = "1.0.0";
      src = ./kodi-moonlight-addon;
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
        QT_QPA_PLATFORM=eglfs ${pkgs.moonlight-qt}/bin/moonlight-qt
      fi
    done
  '';
in
{
  imports = [ ./hardware-configuration.nix ];

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

  users.users.htpc = {
    isNormalUser = true;
    extraGroups = [
      "video"
      "render"
      "input"
      "dialout" # Pulse-Eight USB-CEC adapter (ttyACM)
    ];
  };

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "changeme"; # run `passwd` on first login
  };

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
    settings.PermitRootLogin = "no";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # First install of this box; do not bump on upgrades.
  system.stateVersion = "26.05";
}

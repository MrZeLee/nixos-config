{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ../../../system
  ];

  networking.hostName = "nitro";
  system.stateVersion = "26.05";

  # ponytail: bus IDs copied from laptop; verify with `lspci | grep -E 'VGA|3D'`
  hardware.nvidia.prime = {
    sync.enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # Plasma for gloria; mrzelee keeps Hyprland (pick it once in SDDM).
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = lib.mkForce "plasma";
  # plasma6 and system/services/sddm.nix both set the same kdePackages.sddm
  services.displayManager.sddm.package = lib.mkForce pkgs.kdePackages.sddm;
  # Shared qt.nix exports qt5ct/adwaita-dark globally, which breaks Plasma;
  # hyprland.conf already sets QT_QPA_PLATFORMTHEME for the Hyprland session.
  qt.enable = lib.mkForce false;
  programs.firefox.enable = true;

  users.users.gloria = {
    isNormalUser = true;
    description = "gloria";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = [ pkgs.kdePackages.kate ];
  };
}

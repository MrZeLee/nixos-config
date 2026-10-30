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
  # so krfb is reachable over tailscale after a reboot without someone at the keyboard
  services.displayManager.autoLogin = {
    enable = true;
    user = "gloria";
  };
  # krfb ships no autostart entry; OnlyShowIn keeps it out of mrzelee's Hyprland.
  environment.etc."xdg/autostart/krfb.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=krfb
    Exec=${pkgs.kdePackages.krfb}/bin/krfb --nodialog
    OnlyShowIn=KDE;
  '';
  # Portuguese for gloria: only startplasma reads plasma-localerc, so Hyprland stays en_US.
  environment.etc."xdg/plasma-localerc".text = ''
    [Formats]
    LANG=pt_PT.UTF-8

    [Translations]
    LANGUAGE=pt_PT:pt
  '';
  # hyprlock enables hypridle for every graphical session; it crashes under KWin.
  systemd.user.services.hypridle.unitConfig.ConditionEnvironment = "HYPRLAND_INSTANCE_SIGNATURE";
  # plasma6 and system/services/sddm.nix both set the same kdePackages.sddm
  services.displayManager.sddm.package = lib.mkForce pkgs.kdePackages.sddm;
  # Shared qt.nix exports qt5ct/adwaita-dark globally, which breaks Plasma;
  # hyprland.conf already sets QT_QPA_PLATFORMTHEME for the Hyprland session.
  # Keep qt.enable: it provides QML2_IMPORT_PATH/QT_PLUGIN_PATH, without which
  # plasmashell can't load the desktop/panel and the session stays black.
  qt.platformTheme = lib.mkForce null;
  qt.style = lib.mkForce null;
  programs.firefox.enable = true;
  # Firefox follows LANG, so this only kicks in for the Plasma session
  programs.firefox.languagePacks = [ "pt-PT" ];
  programs.gnupg.agent.enable = true;
  # lets gloria toggle tailscale (and trayscale) without sudo
  services.tailscale.extraSetFlags = [ "--operator=gloria" ];

  users.users.gloria = {
    isNormalUser = true;
    description = "gloria";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = [
      pkgs.kdePackages.kate
      pkgs.kdePackages.krfb
      pkgs.keepassxc
      pkgs.owncloud-client
      pkgs.trayscale
    ];
  };
}

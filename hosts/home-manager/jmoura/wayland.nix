{
  pkgs,
  config,
  ...
}: let
  # Wrap packages with nixGL for OpenGL support on non-NixOS systems
  wrapGL = pkg: config.lib.nixGL.wrap pkg;
in {
  home.packages = with pkgs; [
    # Hyprland compositor and core tools
    (wrapGL hyprland)
    hypridle
    hyprlock
    hyprpaper

    # Hyprland plugins (note: may need version matching with hyprland)
    hyprlandPlugins.hy3  # Uncomment if you need hy3 plugin

    # Status bar
    (wrapGL waybar)

    # Application launcher
    fuzzel

    # Notifications
    mako
    libnotify

    # Wallpaper
    swww
    (wrapGL waypaper)

    # Screen locking (swaylock-effects is a superset of swaylock with blur/effects)
    swaylock-effects

    # Screenshot & screen recording
    grim
    slurp
    swappy
    wf-recorder

    # Clipboard
    cliphist
    wl-clipboard

    # File manager (used in your config)
    nautilus

    # Utilities
    wlr-randr
    wdisplays
    brightnessctl
    playerctl
    pamixer

    # XDG portal for screen sharing
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk

    # Polkit agent (for GUI privilege escalation)
    polkit_gnome
  ];

  # Set Hyprland-related environment variables
  home.sessionVariables = {
    HYPRLAND_HY3 = "${pkgs.hyprlandPlugins.hy3}";
  };

  # Enable XDG portal
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };
}

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
    # NOTE:using dotfiles installtion so it can use pam
    # hyprlock
    hypridle
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
    # LD_LIBRARY_PATH = "$HOME/.nix-profile/lib:/usr/local/lib\${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}";
  };

  # Enable XDG portal for screen sharing
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config = {
      common.default = ["gtk"];
      hyprland.default = ["gtk" "hyprland"];
    };
  };

  gtk = {
    gtk3 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
        gtk-cursor-blink = false;
        gtk-recent-files-limit = 20;
      };
      bookmarks = [
        "file://${config.home.homeDirectory}/Documents"
        "file://${config.home.homeDirectory}/Downloads"
        "file://${config.home.homeDirectory}/Music"
        "file://${config.home.homeDirectory}/Pictures"
        "file://${config.home.homeDirectory}/Videos"
      ];
    };
  };

}

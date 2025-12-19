{
  pkgs,
  config,
  ...
}: let
  # Wrap packages with nixGL for OpenGL support on non-NixOS systems
  wrapGL = pkg: config.lib.nixGL.wrap pkg;
in {
  # Cursor theme configuration
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

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
    #used in the hyprland+hyprpaper, to see added monitors
    socat

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
      hyprland.default = ["hyprland" "gtk"];
    };
  };

  # Systemd user services for XDG portals (needed on non-NixOS)
  # Use nix-installed xdg-desktop-portal with correct XDG_DATA_DIRS
  #
  # After home-manager switch, run these commands to enable the services:
  #   systemctl --user daemon-reload
  #   systemctl --user enable xdg-desktop-portal.service xdg-desktop-portal-hyprland.service
  #   systemctl --user restart xdg-desktop-portal-hyprland xdg-desktop-portal
  #
  # The user-level services override the system ones in /usr/lib/systemd/user/
  systemd.user.services.xdg-desktop-portal = {
    Unit = {
      Description = "Portal service (Nix)";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target" "xdg-desktop-portal-hyprland.service"];
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.portal.Desktop";
      ExecStart = "${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal";
      Environment = [
        "XDG_DATA_DIRS=${config.home.profileDirectory}/share:/usr/local/share:/usr/share"
      ];
      Restart = "on-failure";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  systemd.user.services.xdg-desktop-portal-hyprland = {
    Unit = {
      Description = "Portal service (Hyprland implementation)";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.impl.portal.desktop.hyprland";
      ExecStart = "${pkgs.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
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

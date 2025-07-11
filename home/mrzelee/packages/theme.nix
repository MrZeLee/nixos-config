{pkgs, config, isLinux, isDarwin, ...}: {
  gtk = {
    enable = true;

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };

    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };

    font = {
      name = "DejaVu Sans";
      package = pkgs.dejavu_fonts;
      size = 10;
    };

    gtk2.extraConfig = ''
      gtk-can-change-accels = 1
    '';

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

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-cursor-blink = false;
      gtk-recent-files-limit = 20;
    };
  };

  # Optionally, export the GTK_THEME environment variable
  home.sessionVariables = {
    GTK_THEME = "Adwaita-dark";
  };

  home.packages = with pkgs;
    [
      nerd-fonts.hack
      adwaita-icon-theme
    ]
    ++ lib.optionals isLinux [
      catppuccin-sddm
      gnome-themes-extra
      adwaita-icon-theme
      dejavu_fonts
    ]
    ++ lib.optionals isDarwin [];
}

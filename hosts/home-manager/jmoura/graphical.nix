{
  pkgs,
  config,
  ...
}: let
  # Wrap packages with nixGL for OpenGL support
  wrapGL = pkg: config.lib.nixGL.wrap pkg;
in {
  home.packages = with pkgs; [
    # Terminal emulators
    (wrapGL wezterm)
    (wrapGL ghostty)
    (wrapGL kitty)
    (wrapGL enlightenment.terminology)

    # Messaging
    (wrapGL signal-desktop-bin)
    (wrapGL telegram-desktop)
    (wrapGL vesktop)
    (wrapGL caprine)
    (wrapGL teams-for-linux)
    (wrapGL zoom-us)

    # Media
    (wrapGL mpv)
    (wrapGL spotify)
    (wrapGL gimp)
    (wrapGL swayimg)

    # Security
    (wrapGL keepassxc)

    # Utilities
    (wrapGL localsend)
    (wrapGL pdfpc)
    (wrapGL libreoffice)

    # Editors / Viewers
    (wrapGL vscode)
    (wrapGL zathura)
    (wrapGL typora)

    # Development
    (wrapGL pgadmin4-desktopmode)
    (wrapGL postman)
    (wrapGL chromium)

    # Network
    (wrapGL wireshark)

  ];
}

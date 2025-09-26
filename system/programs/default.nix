{
  pkgs,
  lib,
  isX86_64,
  ...
}: {
  imports = [
    ./fonts.nix
    ./xdg.nix
    ./qt.nix
    ./direnv.nix
    ./zsh.nix
    # ./firefox.nix
    ./gamemode.nix
    ./hyprland.nix
    ./noisetorch.nix
    ./pinentry.nix
    ./localsend.nix
  ] ++ lib.optionals isX86_64 [ ./steam.nix ];

  environment.gnome.excludePackages = with pkgs; [
    gnome-calendar #calendar
    gnome-calculator
    gnome-clocks
    gnome-maps
    gnome-photos
    gnome-tour
    gnome-music
    gnome-weather
    epiphany # web browser
    geary # email reader
    gnome-characters
    yelp # Help view
    gnome-contacts
    gnome-initial-setup
  ];

  programs = {
    dconf.enable = true;
  };
}

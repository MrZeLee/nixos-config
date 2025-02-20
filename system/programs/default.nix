{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./fonts.nix
    ./xdg.nix
    ./qt.nix
    ./zsh.nix
    ./steam.nix
    ./firefox.nix
    ./gamemode.nix
    ./hyprland.nix
    ./noisetorch.nix
  ];

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

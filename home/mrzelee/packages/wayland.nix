{pkgs, ...}: {
  home.packages = with pkgs; [
    waybar
    fuzzel
    mako
    libnotify
    swaylock
    swaybg
    waypaper
    swww
  ];
}

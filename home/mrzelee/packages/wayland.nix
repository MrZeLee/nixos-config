{pkgs, ...}: {
  home.packages = with pkgs; [
    waybar
    fuzzel
    mako
    libnotify
    swaybg
    waypaper
    swww
  ];
}

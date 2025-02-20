{pkgs, ...}: {
  home.packages = with pkgs; [
    (pkgs.nerdfonts.override {fonts = ["Hack"];})
    adwaita-icon-theme
    catppuccin-sddm
  ];
}

{pkgs, ...}: {
  home.packages = with pkgs;
    [
      (pkgs.nerdfonts.override {fonts = ["Hack"];})
      adwaita-icon-theme
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      catppuccin-sddm
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [];
}

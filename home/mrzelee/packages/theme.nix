{pkgs, isLinux, isDarwin, ...}: {
  home.packages = with pkgs;
    [
      nerd-fonts.hack
      adwaita-icon-theme
    ]
    ++ lib.optionals isLinux [
      catppuccin-sddm
    ]
    ++ lib.optionals isDarwin [];
}

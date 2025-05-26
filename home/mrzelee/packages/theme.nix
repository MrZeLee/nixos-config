{pkgs, ...}: {
  home.packages = with pkgs;
    [
      nerd-fonts.hack
      adwaita-icon-theme
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      catppuccin-sddm
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [];
}

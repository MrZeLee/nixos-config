{pkgs, ...}: {
  fonts = {
    packages = [
      pkgs.nerd-fonts.hack # Only install Hack Nerd Font
    ];
  };
}

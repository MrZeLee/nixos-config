{pkgs, ...}: {
  fonts = {
    packages = [
      (pkgs.nerdfonts.override {fonts = ["Hack"];}) # Only install Hack Nerd Font
    ];
  };
}

{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./packages
  ];

  home = {
    username = "mrzelee";
    homeDirectory = lib.mkForce "/home/mrzelee";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}

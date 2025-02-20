{pkgs, ...}: {
  imports = [
    ../../../services/darwin/jankyborders.nix
    ../../../services/darwin/tmux.nix
  ];
}

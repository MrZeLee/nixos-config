{inputs, pkgs, ...}: {
  imports = [
    ./terminal
    ./media
    ./cli.nix
    ./theme.nix
    ./utils.nix
    ./gaming.nix
    ./editors.nix
    ./wayland.nix
    ./messaging.nix
    ./development.nix
  ];
}

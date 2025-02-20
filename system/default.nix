{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./core
    ./nix
    ./network
    ./hardware
    ./programs
    ./services
  ];
}

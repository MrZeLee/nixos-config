{pkgs, ...}: {
  imports = let
    system = pkgs.stdenv.hostPlatform.system;
  in
    if system == "x86_64-linux"
    then [
      ./core
      ./network
      ./hardware
      ./programs
      ./nix
      ./services
    ]
    else if system == "aarch64-darwin"
    then [
      ./programs/fonts.nix
      ./programs/direnv.nix
      ./nix
      ./services
      ./core/users.nix
    ]
    else [];
}

{pkgs, ...}: {
  imports = let
    system = pkgs.stdenv.hostPlatform.system;
  in
    if system == "x86_64-linux"
    then [
      ./noisetorch.nix
      ./ssh.nix
      ./sddm.nix
      ./power.nix
      ./printing.nix
      ./gnome-keyring.nix
      ./cloudflare-warp.nix
      ./docker.nix
    ]
    else if system == "aarch64-darwin"
    then [
      ./jankyborders.nix
      ./tmux.nix
      ./dbus.nix
    ]
    else [];
}

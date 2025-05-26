{isDarwin, isLinux, ...}: {
  imports =
    if isLinux
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
    else if isDarwin
    then [
      ./jankyborders.nix
      ./tmux.nix
      ./dbus.nix
    ]
    else [];
}

{isDarwin, isLinux, ...}: {
  imports =
    if isLinux
    then [
      ./core
      ./network
      ./hardware
      ./programs
      ./nix
      ./services
    ]
    else if isDarwin
    then [
      ./programs/fonts.nix
      ./programs/direnv.nix
      ./programs/pinentry_mac.nix
      ./nix
      ./services
      ./core/users.nix
    ]
    else [];
}

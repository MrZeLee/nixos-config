{
  pkgs,
  lib,
  isLinux,
  isDarwin,
  ...
}: {
  imports =
    if isLinux
    then [
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
      ./network.nix
    ]
    else if isDarwin
    then [
      ./terminal
      ./media
      ./cli.nix
      ./theme.nix
      ./utils.nix
      ./editors.nix
      ./messaging.nix
      ./development.nix
      ./aerospace.nix
      ./network.nix
    ]
    else [];

  home = let
    system = pkgs.stdenv.hostPlatform.system;
    in
    lib.mkIf (system == "aarch64-darwin") {
    activation = {
      prepareStow = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p /Users/mrzelee/.config
        cd /Users/mrzelee/.dotfiles
        run ${pkgs.stow}/bin/stow -d /Users/mrzelee/.dotfiles -t /Users/mrzelee --restow .
      '';
      brotabInstall = lib.hm.dag.entryAfter ["writeBoundary"] ''
        run ${pkgs.brotab}/bin/brotab install
        chmod 666 /tmp/brotab.log || true
        chmod 666 /tmp/brotab_mediator.log || true
        mkdir -p /Users/mrzelee/Library/Application\ Support/Mozilla || true
        mkdir -p /Users/mrzelee/Library/Application\ Support/Mozilla/NativeMessagingHosts || true
        ln -sf /Users/mrzelee/.mozilla/native-messaging-hosts/brotab_mediator.json /Users/mrzelee/Library/Application\ Support/Mozilla/NativeMessagingHosts/
      '';
      npmInstall = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p /Users/mrzelee/.npm-global
      '';
    };
  };
}

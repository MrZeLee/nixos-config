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
      ./librewolf.nix
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
      ./librewolf.nix
    ]
    else [];

  home = lib.mkIf isDarwin {
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
        rm /Users/mrzelee/Library/Application\ Support/Mozilla/NativeMessagingHosts/brotab_mediator.json
        ln -sf /Users/mrzelee/.mozilla/native-messaging-hosts/brotab_mediator.json /Users/mrzelee/Library/Application\ Support/Mozilla/NativeMessagingHosts/
      '';
      npmInstall = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p /Users/mrzelee/.npm-global
      '';
    };
  };
}

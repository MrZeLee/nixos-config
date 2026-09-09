{
  pkgs,
  lib,
  isLinux,
  isDarwin,
  ...
}:
{
  imports = [
    ../shared
    ./extra.nix
    ./librewolf.nix
  ]
  ++ lib.optionals isLinux [
    ./ani-cli
    ./gaming.nix
  ]
  ++ lib.optionals isDarwin [
    ./aerospace.nix
  ];

  home = lib.mkIf isDarwin {
    activation = {
      prepareStow = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p /Users/mrzelee/.config
        cd /Users/mrzelee/.dotfiles
        run ${pkgs.stow}/bin/stow -d /Users/mrzelee/.dotfiles -t /Users/mrzelee --restow .
      '';
      brotabInstall = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${pkgs.brotab}/bin/brotab install
        chmod 666 /tmp/brotab.log || true
        chmod 666 /tmp/brotab_mediator.log || true
        mkdir -p /Users/mrzelee/Library/Application\ Support/Mozilla || true
        mkdir -p /Users/mrzelee/Library/Application\ Support/Mozilla/NativeMessagingHosts || true
        rm /Users/mrzelee/Library/Application\ Support/Mozilla/NativeMessagingHosts/brotab_mediator.json
        ln -sf /Users/mrzelee/.mozilla/native-messaging-hosts/brotab_mediator.json /Users/mrzelee/Library/Application\ Support/Mozilla/NativeMessagingHosts/
      '';
      npmInstall = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p /Users/mrzelee/.npm-global
      '';
    };
  };
}

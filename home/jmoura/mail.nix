# aerc against Stalwart (mrzelee repo, cluster/31-mail). accounts.conf is an
# agenix secret so the mail domain stays out of this public repo; the App
# Password itself comes from `pass` at runtime.
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.agenix.homeManagerModules.default ];

  # Passphrase-less per-machine key: age can't prompt for the user1 passphrase.
  age.identityPaths = [ "${config.home.homeDirectory}/.config/age/home.txt" ];

  # Symlinked in place; mode 0400 satisfies aerc's owner-only check.
  age.secrets.aerc-accounts = {
    file = ../../secrets/aerc-accounts.conf.age;
    path = "${config.xdg.configHome}/aerc/accounts.conf";
  };

  programs.aerc.enable = true;

  # Contacts: vdirsyncer syncs Stalwart CardDAV to ~/.local/share/contacts and
  # khard (config in ~/.dotfiles) edits them. The config is a secret too: its
  # URL carries the domain. Read from vdirsyncer's default path.
  age.secrets.vdirsyncer-config = {
    file = ../../secrets/vdirsyncer-config.age;
    path = "${config.xdg.configHome}/vdirsyncer/config";
  };
  home.packages = [
    pkgs.khard
    pkgs.vdirsyncer
  ];
  services.vdirsyncer.enable = true;
  # The timer doesn't get the login PATH, and password.fetch runs `pass`.
  systemd.user.services.vdirsyncer.Service.Environment = [
    "PATH=${lib.makeBinPath [ pkgs.pass ]}"
  ];
}

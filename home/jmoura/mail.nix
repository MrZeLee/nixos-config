# aerc against Stalwart (mrzelee repo, cluster/31-mail). accounts.conf is an
# agenix secret so the mail domain stays out of this public repo; the App
# Password itself comes from `pass` at runtime.
{ config, inputs, ... }:
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
}

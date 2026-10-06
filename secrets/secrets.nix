# agenix recipients (same layout as nixos-cluster-config). user1 = personal
# key for `agenix -e`; per-machine passphrase-less age keys decrypt at
# activation, since age can't prompt for the user1 passphrase there.
let
  user1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxGPJr0yZ9d+SOYqmEBP2GPejrfbAc45Ijsvk3PWYEP";
  jmoura-popos = "age17kl60zqzxxq8cxce6pxaczt84dj8m6cvfp3rkxydxe5ap2jauftslkj7yx"; # ~/.config/age/home.txt
  homes = [ jmoura-popos ];

  # NixOS hosts decrypt with their SSH host key:
  # `cat /etc/ssh/ssh_host_ed25519_key.pub` on each, then `agenix -r`.
  # TODO: desktop = "ssh-ed25519 ..."; laptop = "...";
  macbook-nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKrHFKOsiSq/ShpAW8VZ5AZitBGMlPSseS2c4VHHpUuQ";
  systems = [ macbook-nixos ];
in
{
  "aerc-accounts.conf.age".publicKeys = systems ++ homes ++ [ user1 ];
  "vdirsyncer-config.age".publicKeys = systems ++ homes ++ [ user1 ];
}

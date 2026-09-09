# Módulos partilhados entre os utilizadores (mrzelee, jmoura).
# Pacotes exclusivos de um utilizador vivem fora desta pasta.
{ lib, isLinux, ... }:
{
  imports = [
    ./cli.nix
    ./terminal
    ./editors.nix
    ./development.nix
    ./network.nix
    ./oidc-agent.nix
    ./messaging.nix
    ./media
    ./theme.nix
    ./utils.nix
  ]
  ++ lib.optionals isLinux [ ./wayland.nix ];
}

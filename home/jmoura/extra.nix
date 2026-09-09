# Pacotes exclusivos do jmoura; o resto vem de ../mrzelee/shared.
{
  pkgs,
  config,
  ...
}:
let
  wrapGL = config.lib.nixGL.wrap;
in
{
  home.packages = with pkgs; [
    # CLI
    direnv
    dos2unix
    aria2
    gnugrep
    gnused
    gnupatch
    mermaid-cli
    meld
    awscli2
    ollama-vulkan
    (spotify-player.override {
      withAudioBackend = "pulseaudio";
    })

    # Graphical
    (wrapGL moonlight-qt)
    (wrapGL localsend)
    (wrapGL neo4j)
    (wrapGL drawio)
  ];
}

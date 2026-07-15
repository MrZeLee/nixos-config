{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  homeDir = config.home.homeDirectory;
in
{
  imports = [
    ./cli.nix
    ./graphical.nix
    ./wayland.nix
  ];

  # Pop!_OS specific home-manager configurations

  home.username = lib.mkForce "jmoura";
  home.homeDirectory = lib.mkForce "/home/jmoura";
  home.stateVersion = "24.11";

  # Enable nixGL for OpenGL support on non-NixOS systems
  targets.genericLinux.nixGL = {
    inherit (inputs.nixgl) packages;
    defaultWrapper = "mesa"; # Intel Arc uses Mesa
    installScripts = [ "mesa" ];
  };

  # set the user uid and install uidmap in root
  home.sessionVariables = {
    DOCKER_HOST = "unix:///run/user/1000/docker.sock";
    LIBSQLITE = "${pkgs.sqlite.out}/lib/libsqlite3.so";
  };

  systemd.user.services.docker = {
    Unit.Description = "Docker (Rootless)";
    # Allow containers to reach the host via 10.0.2.2 (e.g. pgadmin -> local postgres)
    Service.Environment = [ "DOCKERD_ROOTLESS_ROOTLESSKIT_DISABLE_HOST_LOOPBACK=false" ];
    Service.ExecStart = "${pkgs.docker}/bin/dockerd-rootless";
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.ollama = {
    Unit.Description = "Ollama LLM Server (Vulkan)";
    Service.ExecStart = "${pkgs.ollama-vulkan}/bin/ollama serve";
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.ollama-pull = {
    Unit = {
      Description = "Pull Ollama models";
      After = [ "ollama.service" ];
      Requires = [ "ollama.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.ollama-vulkan}/bin/ollama pull qwen3:4b'";
      RemainAfterExit = true;
    };
    Install.WantedBy = [ "default.target" ];
  };

  home.activation = {
    prepareStow = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${homeDir}/.config
      cd ${homeDir}/.dotfiles
      run ${pkgs.stow}/bin/stow -d ${homeDir}/.dotfiles -t ${homeDir} --restow .
    '';
    npmInstall = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${homeDir}/.npm-global
    '';
  };
}

{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  homeDir = config.home.homeDirectory;
in {
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
  nixGL = {
    packages = inputs.nixgl.packages;
    defaultWrapper = "mesa"; # Intel Arc uses Mesa
    installScripts = ["mesa"];
  };


  # set the user uid and install uidmap in root
  home.sessionVariables = {
    DOCKER_HOST = "unix:///run/user/1000/docker.sock";
  };
  systemd.user.services.docker = {
    Unit.Description = "Docker (Rootless)";
    Service.ExecStart = "${pkgs.docker}/bin/dockerd-rootless";
    Install.WantedBy = [ "default.target" ];
  };

  home.activation = {
    prepareStow = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p ${homeDir}/.config
      cd ${homeDir}/.dotfiles
      run ${pkgs.stow}/bin/stow -d ${homeDir}/.dotfiles -t ${homeDir} --restow .
    '';
    npmInstall = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p ${homeDir}/.npm-global
    '';
  };
}

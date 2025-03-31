{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs;
    [
      # Languages
      go
      php83
      php83Packages.composer
      lua51Packages.lua
      lua51Packages.luarocks
      julia_19-bin
      python312
      python312Packages.pip
      pipx
      rustc
      nodejs_23
      zulu23

      cargo
      #dependencies
      pkg-config
      libgit2
      openssl

      # Build tools
      gnumake
      cmake
      gcc

      # Git tools
      gh
      gh-dash
      git-lfs
      lazygit
      tig
      opencommit
      koji
      gitflow

      # Cloud/Infrastructure
      ansible
      cloudflared
      docker
      docker-compose
      fleet-cli
      k9s
      kubectl
      kompose
      kubernetes-helm
      kubeseal
      kubetail
      kustomize
      opentofu

      # Documentation
      gnuplot
      graphviz
      texliveFull

      # Automations
      chromedriver
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      #Automations
      chromium
    ];
}

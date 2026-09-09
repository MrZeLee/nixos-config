{
  pkgs,
  lib,
  config,
  isLinux,
  ...
}:
let
  wrapGL = config.lib.nixGL.wrap;
in
{
  home.packages =
    with pkgs;
    [
      # AI
      unstable.claude-code

      # Languages
      go
      php83
      php83Packages.composer
      lua51Packages.lua
      lua51Packages.luarocks
      julia-bin
      unstable.pipx # 26.05 pipx 1.8.0 fails its test suite
      rustc
      nodejs_24
      zulu

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
      lazydocker
      lazyjournal
      tig
      unstable.hunk
      (opencommit.overrideAttrs {
        makeWrapperArgs = [
          "--prefix"
          "NODE_PATH"
          ":"
          "${commitlint}/lib/node_modules/@commitlint/root/node_modules"
        ];
      })
      koji
      gitflow
      pre-commit
      act
      commitlint

      # Cloud/Infrastructure
      ansible
      cloudflared
      docker
      docker-compose
      kind
      fleet-cli
      k9s
      kubectl
      kompose
      kubernetes-helm
      kubeseal
      kubetail
      kustomize
      opentofu
      terraform
      terragrunt
      azure-cli

      # Documentation
      gnuplot
      graphviz
      texliveFull
      unstable.tuxedo

      # Automations
      chromedriver

      #Databases
      (wrapGL pgadmin4-desktopmode)
      unstable.lazysql

      #Testing
      (wrapGL postman)
    ]
    ++ lib.optionals isLinux [
      #Automations
      (wrapGL chromium)
      parted
    ];
}

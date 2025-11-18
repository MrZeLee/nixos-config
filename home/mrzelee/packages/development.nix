{
  pkgs,
  lib,
  isLinux,
  ...
}: {
  home.packages = with pkgs;
    [
      # AI
      unstable.codex
      unstable.opencode
      unstable.claude-code

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
      nodejs_24
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
      pre-commit
      act

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
      postgresql
      terraform
      terragrunt
      azure-cli

      # Documentation
      gnuplot
      graphviz
      texliveFull

      # Automations
      chromedriver

      #Databases
      pgadmin4-desktopmode
      unstable.lazysql
      # (writeShellScriptBin "harlequin" ''
      #   # Ensure harlequin is installed with all dependencies
      #   if ! ${uv}/bin/uv tool list 2>/dev/null | grep -q "harlequin"; then
      #     echo "Installing harlequin with uv..." >&2
      #     ${uv}/bin/uv tool install 'harlequin[postgres]'
      #   fi
      #   # Run harlequin via uv
      #   exec ${uv}/bin/uv tool run harlequin "$@"
      # '')

      #Testing
      postman
      age
    ]
    ++ lib.optionals isLinux [
      #Automations
      chromium
      parted
    ];
}

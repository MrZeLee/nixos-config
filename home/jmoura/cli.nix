{
  pkgs,
  inputs,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      # Shell & Terminal utilities
      tmux
      zsh
      btop
      bat
      eza
      tree
      zoxide
      fastfetch
      watch
      glow
      tldr
      fzf
      jq
      direnv
      wiremix
      (ledger.override {
        gpgmeSupport = true;
        usePython = true;
      })

      # File utilities
      stow
      vimv-rs
      exiftool
      moreutils
      rclone
      croc
      p7zip
      poppler
      imagemagick

      # Yazi file manager
      yazi
      ffmpegthumbnailer

      # Network utilities
      wget
      curl
      nmap
      netcat
      dnsutils
      speedtest-cli
      ddgr
      lynx
      openvpn
      wireguard-tools
      sshfs
      teleport_17
      aria2

      # Security
      gnupg
      pass
      age

      # System utilities
      pciutils
      usbutils
      lshw
      parted
      gnugrep
      gnused
      gnupatch

      # Editors & Neovim dependencies
      neovim
      wl-clipboard
      lua-language-server
      marksman
      ruff
      stylua
      prettier
      prettierd
      markdown-toc
      markdownlint-cli2
      sqlite
      libxml2
      nil
      nixfmt-rfc-style
      statix
      unstable.tree-sitter
      ripgrep
      fd
      pstree
      yarn
      mermaid-cli
      mercurial
      ast-grep
      python3Packages.pylatexenc

      # Archive tools
      zip
      unzip
      gzip
      gnutar

      # Languages & Runtimes
      go
      php83
      php83Packages.composer
      lua51Packages.lua
      lua51Packages.luarocks
      julia-bin
      (python312.withPackages (
        ps: with ps; [
          pip
          flatlatex
        ]
      ))
      uv
      pipx
      unstable.rustc
      cargo
      nodejs_24
      zulu

      # Build tools
      gnumake
      cmake
      gcc
      pkg-config
      libgit2
      openssl
      glibc

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
      meld
      commitlint
      ollama-vulkan

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
      unstable.awscli2

      # Databases
      (postgresql.withPackages (pp: [
        pp.pgvector
      ]))
      unstable.lazysql

      # Documentation
      gnuplot
      graphviz
      texliveFull
      ghostscript
      unstable.tuxedo

      # Media CLI tools
      ffmpeg_6-full
      (unstable.spotify-player.override {
        withAudioBackend = "pulseaudio";
      })

      # Image libraries (dependencies)
      giflib
      libjpeg
      libjxl
      libpng
      librsvg
      libwebp
      libheif
      libavif
      libtiff
      libsixel

      # Fonts & Themes
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack

      # Misc CLI
      abook
      brotab
      cacert
      cht-sh
      gowall
      gettext
      xdotool
      chromedriver
      bluetui

      # AI tools
      unstable.claude-code

      dos2unix
      qmk
      nvd
    ]
    ++ [
      # Custom packages
      (pkgs.callPackage (inputs.mvd + "/default.nix") { })
    ];

  fonts.fontconfig.enable = true;
}

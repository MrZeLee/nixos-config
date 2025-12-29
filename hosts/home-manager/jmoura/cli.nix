{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    # Shell & Terminal utilities
    tmux
    zsh
    btop
    bat
    eza
    tree
    zoxide
    neofetch
    watch
    glow
    tldr
    fzf
    jq
    direnv

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
    prettierd
    libxml2
    tree-sitter
    ripgrep
    fd
    pstree
    yarn

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
    python312
    python312Packages.pip
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
    terraform
    terragrunt
    azure-cli

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

    # Media CLI tools
    ffmpeg_6-full
    (master.spotify-player.override {
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
  ]
  ++ [
    # Custom packages
    (pkgs.callPackage (inputs.mvd + "/default.nix") {})
  ];
}

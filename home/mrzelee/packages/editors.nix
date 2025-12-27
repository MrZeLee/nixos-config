{
  pkgs,
  lib,
  isLinux,
  isDarwin,
  isX86_64,
  ...
}: {
  home.packages = with pkgs;
    [
      # Neovim and dependencies

      neovim
      # Neovim
      wl-clipboard
      ## LSP
      lua-language-server
      marksman
      ruff
      ## img-clip
      # pngpaste # For MacOs
      ## Mason Core
      zip
      unzip
      wget
      curl
      gzip
      gnutar # bash sh
      ## Mason Languages
      ###Formatters
      stylua
      prettierd
      #### xmllint
      libxml2

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
      rustc
      cargo
      nodejs_24
      zulu
      texliveFull
      ## Treesitter
      tree-sitter
      gcc # nodejs_22 git
      ## Telescope
      ripgrep
      fd
      ## VimTex
      pstree
      #MarkdownPreview
      yarn

      # VSCode
      pkgs.vscode
      glibc
      postgresql

      # Document viewers
      zathura
    ]
    ++ lib.optionals isLinux [
      ## VimTex dependencies
      xdotool
    ]
    ++ lib.optionals (isLinux && isX86_64) [
      typora
    ]
    ++ lib.optionals isDarwin [
    ];
}

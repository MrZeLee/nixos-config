{
  pkgs,
  lib,
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
      ## img-clip
      # pngpaste # For MacOs
      ## Mason Core
      unzip
      wget
      curl
      gzip
      gnutar # bash sh
      ## Mason Languages
      ###Formatters
      stylua
      prettierd

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
      cargo
      nodejs_23
      zulu23
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

      # Document viewers
      zathura
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      ## VimTex dependencies
      xdotool
      typora
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
    ];
}

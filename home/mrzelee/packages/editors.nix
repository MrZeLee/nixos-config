{
  pkgs,
  lib,
  isLinux,
  isDarwin,
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
      isort
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
      julia_19-bin
      python312
      python312Packages.pip
      pipx
      rustc
      cargo
      nodejs_24
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
    ++ lib.optionals isLinux [
      ## VimTex dependencies
      xdotool
      typora
    ]
    ++ lib.optionals isDarwin [
    ];
}

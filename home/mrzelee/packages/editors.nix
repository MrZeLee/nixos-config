{
  pkgs,
  lib,
  isLinux,
  isDarwin,
  isX86_64,
  ...
}:
{
  home.sessionVariables = {
    LIBSQLITE = "${pkgs.sqlite.out}/lib/libsqlite3.so";
  };

  home.packages =
    with pkgs;
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
      prettier
      prettierd
      markdown-toc
      markdownlint-cli2
      python3Packages.pylatexenc
      sqlite
      #### xmllint
      libxml2
      #### nix
      nil
      nixfmt
      statix

      ## diffview
      mercurial

      ## grup-far
      ast-grep

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
      unstable.pipx # 26.05 pipx 1.8.0 fails its test suite
      rustc
      cargo
      nodejs_24
      zulu
      texliveFull
      ## Treesitter
      unstable.tree-sitter
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

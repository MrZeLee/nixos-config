{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs;
    [
      abook
      bat
      brotab
      cacert
      cht-sh
      croc
      ddgr
      eza
      exiftool
      glow
      gowall
      gettext
      lynx
      moreutils
      neofetch
      rclone
      speedtest-cli
      stow
      tldr
      tree
      vimv-rs
      watch
      zoxide
    ]
    ++ [
      (pkgs.callPackage
      (inputs.mvd + "/default.nix")
      {})
    ];
}

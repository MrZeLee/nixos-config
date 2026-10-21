{
  pkgs,
  inputs,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      abook
      bat
      brotab
      # same eMudhra distrust as hosts/nixos/default.nix; drop with it
      (cacert.override {
        blacklist = [
          "Comodo AAA Services root"
          "emSign ECC Root CA - G3"
        ];
      })
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
      fastfetch
      rclone
      oidc-agent
      speedtest-cli
      stow
      tldr
      tree
      vimv-rs
      watch
      zoxide
      wiremix

      qmk
      nvd
    ]
    ++ [
      (pkgs.callPackage (inputs.mvd + "/default.nix") { })
    ];
}

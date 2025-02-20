{pkgs, ...}: {
  home.packages = with pkgs; [
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
    tldr
    tree
    vimv-rs
    watch
    zoxide
  ];
}

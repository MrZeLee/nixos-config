{pkgs, ...}: {
  home.packages = with pkgs; [
    yazi

    #dependencies
    ffmpegthumbnailer
    p7zip
    jq
    poppler
    fd
    ripgrep
    fzf
    zoxide
    imagemagick
  ];
}

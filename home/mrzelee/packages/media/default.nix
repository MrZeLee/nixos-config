{pkgs, ...}: {
  home.packages = with pkgs; [
    # Image
    gimp

    swayimg
    #dependencies
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

    grim
    slurp

    # Audio/Video
    spotify
    spotify-player
    mpv
    ffmpeg_6-full
    pavucontrol

    # File management
    nemo-with-extensions
    gvfs
    udisks2
    gphoto2
    libmtp
    cinnamon-desktop
    shared-mime-info
    xdg-utils
  ];
}

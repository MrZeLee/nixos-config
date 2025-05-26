{pkgs, isLinux, isDarwin, ...}: {

  imports = [ ./ani-cli ];

  home.packages = with pkgs;
    [
      # Image
      gimp

      # Audio/Video
      spotify
      unstable.spotify-player
      mpv
      ffmpeg_6-full
    ]
    ++ lib.optionals isLinux [
      #Image
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

      #Audio/Video
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
    ]
    ++ lib.optionals isDarwin [
    ];
}

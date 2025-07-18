{pkgs, lib, hostname, isLinux, isDarwin, isX86_64, ...}: {

  imports = [ ./ani-cli ];

  home.packages = with pkgs;
    [
      # Image
      gimp

      # Audio/Video
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
    ++ lib.optionals (isLinux && isX86_64) [
      spotify
    ]
    ++ lib.optionals isDarwin [
      spotify
    ];

  home.file = lib.mkIf (hostname == "macbook-nixos") {
    ".config/mpv/mpv.conf".text = ''
      vo=gpu
      gpu-api=opengl
      gpu-context=wayland
    '';
  };
}

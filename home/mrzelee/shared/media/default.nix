{
  pkgs,
  lib,
  config,
  hostname,
  isLinux,
  isDarwin,
  isX86_64,
  ...
}:
let
  wrapGL = config.lib.nixGL.wrap;
in
{
  home.packages =
    with pkgs;
    [
      # Image
      (wrapGL gimp)

      # Audio/Video
      (wrapGL mpv)
      ffmpeg_6-full
    ]
    ++ lib.optionals isLinux [
      #Image
      (wrapGL swayimg)
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
      (wrapGL pavucontrol)
    ]
    ++ lib.optionals (isLinux && isX86_64) [
      (wrapGL spotify)
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

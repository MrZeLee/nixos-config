{
  self,
  inputs,
  pkgs,
  ...
}: {
  nixpkgs = {
    config.allowUnfree = true;
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Base libraries
      glibc
      libxcrypt-legacy

      # Graphics libraries (for Unity games)
      xorg.libX11
      xorg.libXcursor
      xorg.libXrandr
      xorg.libXi
      xorg.libXinerama
      xorg.libXext
      xorg.libXrender
      xorg.libXfixes

      # OpenGL/Vulkan
      libGL
      libglvnd
      vulkan-loader

      # Audio libraries
      alsa-lib
      libpulseaudio

      # Common system libraries
      zlib
      stdenv.cc.cc.lib

      # Wayland support
      wayland
      libxkbcommon

      # Additional libraries Unity might need
      dbus
      fontconfig
      freetype
    ];
  };

  # environment.sessionVariables = {
  #   NIX_LD_LIBRARY_PATH = "/run/current-system/sw/share/nix-ld/lib";
  #   NIX_LD = "/run/current-system/sw/share/nix-ld/lib/ld.so";
  # };
}

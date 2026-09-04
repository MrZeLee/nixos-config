{
  self,
  inputs,
  pkgs,
  lib,
  isLinux,
  ...
}:
{
  nixpkgs = {
    config.allowUnfree = true;
  };
}
// lib.optionalAttrs isLinux {
  # nix-ld is NixOS-only; the option doesn't exist on nix-darwin
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Base libraries
      glibc
      libxcrypt-legacy

      # Graphics libraries (for Unity games)
      libx11
      libxcursor
      libxrandr
      libxi
      libxinerama
      libxext
      libxrender
      libxfixes

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

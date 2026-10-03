{ lib, pkgs, ... }:
{
  programs.localsend.enable = true;
  # The prebuilt aarch64 Flutter engine lacks fontconfig and renders no text
  # (localsend/localsend#2873); build against the nixpkgs source engine instead.
  # 1.18 needs Flutter 3.41 (only packaged on master); master dropped the
  # source engine, so take it from stable.
  programs.localsend.package = lib.mkIf pkgs.stdenv.hostPlatform.isAarch64 (
    pkgs.master.localsend.override { flutter341 = pkgs.flutterPackages-source.v3_41; }
  );
}

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
      glibc
      libxcrypt-legacy
    ];
  };

  # environment.sessionVariables = {
  #   NIX_LD_LIBRARY_PATH = "/run/current-system/sw/share/nix-ld/lib";
  #   NIX_LD = "/run/current-system/sw/share/nix-ld/lib/ld.so";
  # };
}

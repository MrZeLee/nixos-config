{ inputs, nixpkgs, ... }:

{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.nur.overlays.default
      (final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (prev.stdenv.hostPlatform) system;
          config.allowUnfree = true;
        };
      })
      # (final: prev: {
      #   unstable = inputs.nixpkgs-unstable.legacyPackages.${prev.system};
      # })
      (import ../pkgs/overlay.nix { inherit nixpkgs; })
    ];
  };
}


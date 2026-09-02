{ inputs, nixpkgs, ... }:

{
  nixpkgs = {
    config = {
      allowUnfree = true;
      # pnpm 10.29.2 is the build-time package manager for most Electron/Node
      # apps in 26.05 (signal, vesktop, mpv, teleport, prettier, ...); flagged
      # insecure but never present in or run by the resulting apps.
      permittedInsecurePackages = [ "pnpm-10.29.2" ];
    };
    overlays = [
      inputs.nur.overlays.default
      (final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (prev.stdenv.hostPlatform) system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [ "pnpm-10.29.2" ];
          };
        };
        master = import inputs.nixpkgs-master {
          inherit (prev.stdenv.hostPlatform) system;
          config.allowUnfree = true;
        };
      })
      # (final: prev: {
      #   unstable = inputs.nixpkgs-unstable.legacyPackages.${prev.system};
      # })
      (import ../pkgs/overlay.nix { inherit nixpkgs; })
      inputs.nixos-apple-silicon.overlays.apple-silicon-overlay
    ];
  };
}

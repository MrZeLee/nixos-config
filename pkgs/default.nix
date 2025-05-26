{ inputs }:
let
  systems = ["x86_64-linux" "aarch64-darwin"];
  forAllSystems = inputs.nixpkgs.lib.genAttrs systems;

  overlay = import ./overlay.nix {};
in
  forAllSystems (system:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [overlay];
      };

      # Define packages based on system
      systemPackages =
        if system == "x86_64-linux"
        then {
          inherit
            (pkgs)
            waypaper
            swww
            fleet-cli
            wezterm
            # koji
            mmex
            gnucash
            ;
        }
        else {
          inherit
            (pkgs)
            fleet-cli
            # koji
            ;
        };
    in
      systemPackages
  )

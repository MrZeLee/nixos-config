{inputs}: let
  systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
  forAllSystems = inputs.nixpkgs.lib.genAttrs systems;

  overlay = import ./overlay.nix {nixpkgs = inputs.nixpkgs;};
in
  forAllSystems (
    system: let
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
            # wezterm
            # koji
            mmex
            codex
            # gnucash
            ;
        }
        else if system == "aarch64-linux"
        then {
          inherit
            (pkgs)
            waypaper
            swww
            fleet-cli
            # wezterm
            # koji
            mmex
            codex
            # gnucash
            ;
        }
        else {
          inherit
            (pkgs)
            fleet-cli
            codex
            # koji
            ;
        };
    in
      systemPackages
  )

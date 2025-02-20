{nixpkgs}: let
  systems = ["x86_64-linux" "aarch64-darwin"];
  forAllSystems = nixpkgs.lib.genAttrs systems;
  overlay = import ./overlay.nix {inherit nixpkgs;};
in
  forAllSystems (
    system: let
      pkgs = import nixpkgs {
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
            koji
            ;
        }
        else {
          inherit
            (pkgs)
            fleet-cli
            wezterm
            koji
            ;
        };
    in
      systemPackages
  )

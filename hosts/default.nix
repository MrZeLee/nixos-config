{
  inputs,
  nixpkgs,
  system,
}: let
  mkSystem = hostname: extraModules: let
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        (final: prev: {
          unstable = inputs.nixpkgs-unstable.legacyPackages.${prev.system};
        })
        (import ../pkgs/overlay.nix {inherit nixpkgs;})
      ];
    };
  in {
    ${hostname} = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs pkgs;};
      modules =
        [
          ./nixos/${hostname}
          inputs.home-manager.nixosModules.home-manager
          ({config, ...}: {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.mrzelee = import ../home/mrzelee;
              extraSpecialArgs = {
                inherit inputs;
                osConfig = config;
              };
            };
          })
        ]
        ++ extraModules;
    };
  };
  # mkDarwinSystem = hostname: extraModules: let
  #   pkgs = import nixpkgs {
  #     inherit system;
  #     config.allowUnfree = true;
  #     overlays = [
  #       (final: prev: {
  #         unstable = inputs.nixpkgs-unstable.legacyPackages.${prev.system};
  #       })
  #       (import ../pkgs {inherit nixpkgs;}) # Add your custom packages overlay
  #     ];
  #   };
  # in {
  #   ${hostname} = inputs.nix-darwin.lib.darwinSystem {
  #     inherit system;
  #     specialArgs = {inherit inputs pkgs;};
  #     modules =
  #       [
  #         ./darwin/${hostname}
  #         ../modules/darwin
  #       ]
  #       ++ extraModules;
  #   };
  # };
in {
  nixosConfigurations =
    mkSystem "desktop" [];
  # // (mkSystem "laptop" []);

  # darwinConfigurations =
  #   mkDarwinSystem "laptop" [];
}

{
  inputs,
  nixpkgs,
  system,
  mac-app-util ? null,
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
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.mrzelee = import ../home/mrzelee;
              backupFileExtension = "backup";
              extraSpecialArgs = {
                inherit inputs;
                inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
              };
            };
          }
        ]
        ++ extraModules;
    };
  };
  mkDarwinSystem = hostname: extraModules: let
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        (final: prev: {
          unstable = inputs.nixpkgs-unstable.legacyPackages.${prev.system};
        })
        (import ../pkgs/overlay.nix {inherit nixpkgs;}) # Add your custom packages overlay
      ];
    };

    darwinSystem = inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {inherit inputs pkgs;};
      modules =
        [
          mac-app-util.darwinModules.default
          ./darwin/${hostname}
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              users.mrzelee = import ../home/mrzelee;
              backupFileExtension = "backup";
              extraSpecialArgs = {
                inherit inputs;
                inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
              };
              sharedModules = [
                mac-app-util.homeManagerModules.default
              ];
            };
          }
          ../modules/darwin
        ]
        ++ extraModules;
    };
  in {
    ${hostname} = darwinSystem;
  };
in {
  nixosConfigurations =
    mkSystem "desktop" []
  // (mkSystem "laptop" []);

  darwinConfigurations =
    mkDarwinSystem "mrzelee-mbpro" [];
}

{
  inputs,
  nixpkgs,
  system,
  mac-app-util ? null,
}: let
  mkSystem = hostname: extraModules: {
    ${hostname} = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
        isLinux = builtins.match ".*-linux" system != null;
        isDarwin = builtins.match ".*-darwin" system != null;
      };
      modules =
        [
          ../modules/nixpkgs-overlays.nix
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
                isLinux = builtins.match ".*-linux" system != null;
                isDarwin = builtins.match ".*-darwin" system != null;
              };
            };
          }
        ]
        ++ extraModules;
    };
  };
  mkDarwinSystem = hostname: extraModules: {
    ${hostname} = inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
        isLinux = builtins.match ".*-linux" system != null;
        isDarwin = builtins.match ".*-darwin" system != null;
      };
      modules =
        [
          mac-app-util.darwinModules.default
          ../modules/nixpkgs-overlays.nix
          ./darwin/${hostname}
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              users.mrzelee = import ../home/mrzelee;
              backupFileExtension = "backup";
              extraSpecialArgs = {
                inherit inputs;
                isLinux = builtins.match ".*-linux" system != null;
                isDarwin = builtins.match ".*-darwin" system != null;
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
  };
in {
  nixosConfigurations =
    mkSystem "desktop" []
  // (mkSystem "laptop" []);

  darwinConfigurations =
    mkDarwinSystem "mrzelee-mbpro" [];
}

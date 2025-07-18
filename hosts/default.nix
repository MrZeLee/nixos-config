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
        # Architecture
        isAarch64 = builtins.match "^aarch64-.*" system != null;
        isX86_64 = builtins.match "^x86_64-.*" system != null;
        hostname = hostname;
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
                # Architecture
                isAarch64 = builtins.match "^aarch64-.*" system != null;
                isX86_64 = builtins.match "^x86_64-.*" system != null;
                hostname = hostname;
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
        # Architecture
        isAarch64 = builtins.match "^aarch64-.*" system != null;
        isX86_64 = builtins.match "^x86_64-.*" system != null;
        hostname = hostname;
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
                # Architecture
                isAarch64 = builtins.match "^aarch64-.*" system != null;
                isX86_64 = builtins.match "^x86_64-.*" system != null;
                hostname = hostname;
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
  // (mkSystem "laptop" [])
  // (mkSystem "macbook-nixos" []);

  darwinConfigurations =
    mkDarwinSystem "mrzelee-mbpro" [];
}

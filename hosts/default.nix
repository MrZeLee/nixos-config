{
  inputs,
  nixpkgs,
  agenix,
  system,
  mac-app-util ? null,
}: let
  mkSystem = hostname: extraModules: {
    ${hostname} = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs system;
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
          ./nixos/default.nix
          ./nixos/${hostname}
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.mrzelee = import ../home/mrzelee;
              backupFileExtension = "backup";
              extraSpecialArgs = {
                inherit inputs system;
                isLinux = builtins.match ".*-linux" system != null;
                isDarwin = builtins.match ".*-darwin" system != null;
                # Architecture
                isAarch64 = builtins.match "^aarch64-.*" system != null;
                isX86_64 = builtins.match "^x86_64-.*" system != null;
                hostname = hostname;
              };
            };
          }
          agenix.nixosModules.default
        ]
        ++ extraModules;
    };
  };
  mkDarwinSystem = hostname: extraModules: {
    ${hostname} = inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {
        inherit inputs system;
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
                inherit inputs system;
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
  mkHomeConfiguration = hostname: extraModules: {
    ${hostname} = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {inherit system;};
      extraSpecialArgs = {
        inherit inputs system;
        isLinux = builtins.match ".*-linux" system != null;
        isDarwin = builtins.match ".*-darwin" system != null;
        isAarch64 = builtins.match "^aarch64-.*" system != null;
        isX86_64 = builtins.match "^x86_64-.*" system != null;
        isStandalone = true;
        hostname = hostname;
      };
      modules =
        [
          ../modules/nixpkgs-overlays.nix
          ./home-manager/${hostname}
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

  homeConfigurations =
    mkHomeConfiguration "jmoura" [];
}

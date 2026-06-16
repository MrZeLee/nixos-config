{
  description = "MrZeLee's NixOS Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-tuxedo-pr.url = "github:IogaMaster/nixpkgs/update/tuxedo";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mvd.url = "github:MrZeLee/mvd";

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util.url = "github:hraban/mac-app-util";

    nur.url = "github:nix-community/nur";

    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon/release-2025-11-18";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    iloader.url = "github:nab138/iloader";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      agenix,
      git-hooks,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems f;
      preCommitFor =
        system:
        git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt-rfc-style.enable = true;
            statix = {
              enable = true;
              settings.ignore = [ "**/hardware-configuration.nix" ];
            };
            deadnix = {
              enable = true;
              excludes = [ "hardware-configuration\\.nix$" ];
              settings.noLambdaPatternNames = true;
              settings.noLambdaArg = true;
            };
          };
        };
    in
    {
      checks = forAllSystems (system: {
        pre-commit-check = preCommitFor system;
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          check = preCommitFor system;
        in
        {
          default = pkgs.mkShell {
            inherit (check) shellHook;
            buildInputs = check.enabledPackages;
          };
        }
      );

      nixosConfigurations = {
        # x86_64 hosts
        desktop =
          (import ./hosts {
            inherit inputs nixpkgs agenix;
            system = "x86_64-linux";
          }).nixosConfigurations.desktop;
        laptop =
          (import ./hosts {
            inherit inputs nixpkgs agenix;
            system = "x86_64-linux";
          }).nixosConfigurations.laptop;
        # aarch64 host
        macbook-nixos =
          (import ./hosts {
            inherit inputs nixpkgs agenix;
            system = "aarch64-linux";
          }).nixosConfigurations.macbook-nixos;
      };

      inherit
        (
          (import ./hosts {
            inherit inputs nixpkgs;
            system = "aarch64-darwin";
            inherit (inputs) mac-app-util;
          })
        )
        darwinConfigurations
        ;

      # Standalone home-manager configurations (for non-NixOS Linux like Debian/Pop!_OS)
      inherit
        (
          (import ./hosts {
            inherit inputs nixpkgs;
            agenix = null;
            system = "x86_64-linux";
          })
        )
        homeConfigurations
        ;

      packages = import ./pkgs { inherit inputs; };
    };
}

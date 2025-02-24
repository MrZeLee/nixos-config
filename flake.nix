{
  description = "MrZeLee's NixOS Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
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

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: {
    nixosConfigurations =
      (import ./hosts {
        inherit inputs nixpkgs;
        system = "x86_64-linux";
      })
      .nixosConfigurations;

    darwinConfigurations =
      (import ./hosts {
        inherit inputs nixpkgs;
        system = "aarch64-darwin";
        mac-app-util = inputs.mac-app-util;
      })
      .darwinConfigurations;

    packages = import ./pkgs {inherit nixpkgs;};
  };
}

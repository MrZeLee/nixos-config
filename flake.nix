{
  description = "MrZeLee's NixOS Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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
      url = "github:nix-community/nixos-apple-silicon/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    agenix,
    ...
  }: {
    nixosConfigurations = {
      # x86_64 hosts
      desktop       = (import ./hosts { inherit inputs nixpkgs agenix; system = "x86_64-linux"; }).nixosConfigurations.desktop;
      laptop        = (import ./hosts { inherit inputs nixpkgs agenix; system = "x86_64-linux"; }).nixosConfigurations.laptop;
      # aarch64 host
      macbook-nixos = (import ./hosts { inherit inputs nixpkgs agenix; system = "aarch64-linux"; }).nixosConfigurations.macbook-nixos;
    };

    darwinConfigurations =
      (import ./hosts {
        inherit inputs nixpkgs;
        system = "aarch64-darwin";
        mac-app-util = inputs.mac-app-util;
      })
      .darwinConfigurations;

    packages = import ./pkgs {inherit inputs;};
  };
}

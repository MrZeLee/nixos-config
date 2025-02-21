{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./nixpkgs.nix
  ];

  # we need git for flakes
  environment.systemPackages = [pkgs.git];

  nix = let
    flakeInputs = lib.filterAttrs (_: v: lib.isType "flake" v) inputs;
  in {
    package = pkgs.lix;

    # pin the registry to avoid downloading and evaling a new nixpkgs version every time
    registry = lib.mapAttrs (_: v: {flake = v;}) flakeInputs;

    # set the path for channels compat
    nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;

    settings = {
      experimental-features = ["nix-command" "flakes"];
      builders-use-substitutes = true;

      # Disable auto-optimise-store because of this issue:
      #   https://github.com/NixOS/nix/issues/7273
      # "error: cannot link '/nix/store/.tmp-link-xxxxx-xxxxx' to '/nix/store/.links/xxxx': File exists"
      auto-optimise-store = !(pkgs.stdenv.isDarwin);
      flake-registry = "/etc/nix/registry.json";

      # for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;

      trusted-users = ["root" "@wheel"] ++ lib.optionals pkgs.stdenv.isDarwin ["@admin"];
    };

    # Garbage collection settings
    gc = lib.mkMerge [
      (lib.mkIf pkgs.stdenv.isDarwin {
        automatic = true;
        interval = {
          Hour = 3;
          Weekday = 7;
          Minute = 0;
        };
        options = "--delete-older-than 7d";
      })
      (lib.mkIf pkgs.stdenv.isLinux {
        dates = "weekly";
        options = "--delete-older-than 7d";
      })
    ];
  };

  services.nix-daemon.enable = lib.mkIf pkgs.stdenv.isDarwin true;
}

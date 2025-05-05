{lib, pkgs, ...}: {
  imports = [
    ../../../system
    ../default.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
  system.stateVersion = 4; # Add this line

  networking.hostName = "mrzelee-mbpro";
  networking.computerName = "mrzelee-mbpro";

  # Darwin-specific host configurations
  system = {
    defaults = {
      dock = {
        persistent-apps = [
          "/System/Applications/Launchpad.app"
          "${pkgs.wezterm}/Applications/WezTerm.app"
          "${pkgs.unstable.librewolf}/Applications/Librewolf.app"
          "/Applications/Firefox.app"
          "/Applications/Discord.app"
          "/System/Applications/Messages.app"
          "${pkgs.spotify}/Applications/Spotify.app"
          "${pkgs.keepassxc}/Applications/KeePassXC.app"
        ];
        persistent-others = [
          "/Users/mrzelee/Downloads"
        ];
      };
    };
  };
}

{pkgs, ...}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    gamescopeSession.enable = false;
    extest.enable = false;
    protontricks.enable = true;
    package = pkgs.steam.override {extraLibraries = pkgs: [pkgs.gperftools];};
  };
  hardware.xone.enable = true;
}

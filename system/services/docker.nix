{
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
    daemon = {
      settings = {
        dns = ["1.1.1.1" "8.8.8.8"];
      };
    };
  };

  users.users.mrzelee = {
    extraGroups = [ "docker" ];
  };
}

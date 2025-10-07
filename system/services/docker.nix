{
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  users.users.mrzelee = {
    extraGroups = [ "docker" ];
  };
}

{
  virtualisation.docker = {
    enable = true;
  };

  users.users.mrzelee = {
    extraGroups = [ "docker" ];
  };
}

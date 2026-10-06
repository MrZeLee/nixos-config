{
  config,
  pkgs,
  lib,
  inputs,
  system,
  ...
}:
{
  environment.systemPackages = [
    inputs.agenix.packages."${system}".default
  ];

  # aerc against Stalwart; accounts.conf is an agenix secret so the mail
  # domain stays out of this public repo. Decrypted with the host key and
  # linked into ~ by home-manager (a home-owned dir, unlike agenix's mkdir).
  age.secrets.aerc-accounts = {
    file = ../../secrets/aerc-accounts.conf.age;
    owner = "mrzelee";
  };
  age.secrets.vdirsyncer-config = {
    file = ../../secrets/vdirsyncer-config.age;
    owner = "mrzelee";
  };

  home-manager.users.mrzelee =
    {
      config,
      osConfig,
      lib,
      pkgs,
      ...
    }:
    {
      programs.aerc.enable = true;
      xdg.configFile."aerc/accounts.conf".source =
        config.lib.file.mkOutOfStoreSymlink osConfig.age.secrets.aerc-accounts.path;

      # Contacts: vdirsyncer <-> Stalwart CardDAV, edited with khard.
      home.packages = [
        pkgs.khard
        pkgs.vdirsyncer
      ];
      services.vdirsyncer.enable = true;
      xdg.configFile."vdirsyncer/config".source =
        config.lib.file.mkOutOfStoreSymlink osConfig.age.secrets.vdirsyncer-config.path;
      # The timer doesn't get the login PATH, and password.fetch runs `pass`.
      systemd.user.services.vdirsyncer.Service.Environment = [
        "PATH=${lib.makeBinPath [ pkgs.pass ]}"
      ];
    };
}

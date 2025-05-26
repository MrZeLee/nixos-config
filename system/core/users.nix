{
  pkgs,
  lib,
  isLinux,
  isDarwin,
  ...
}: {
  users.users.mrzelee = lib.mkMerge [
    (lib.mkIf isLinux {
      isNormalUser = true;
      description = "MrZeLee";
      extraGroups = ["networkmanager" "wheel" "video" "render" "input" "uinput" "gamemode"];
      home = "/home/mrzelee";
      createHome = true;
      shell = pkgs.zsh;
      useDefaultShell = false;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxGPJr0yZ9d+SOYqmEBP2GPejrfbAc45Ijsvk3PWYEP mrzelee404@gmail.com"
      ];
    })

    (lib.mkIf isDarwin {
      home = "/Users/mrzelee";
      shell = pkgs.zsh;
    })
  ];
}

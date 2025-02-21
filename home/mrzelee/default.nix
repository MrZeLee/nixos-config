{
  lib,
  isDarwin,
  ...
}: {
  imports = [
    ./packages
  ];

  home = {
    username = "mrzelee";
    homeDirectory =
      lib.mkForce
      (
        if isDarwin
        then "/Users/mrzelee"
        else "/home/mrzelee"
      );
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}

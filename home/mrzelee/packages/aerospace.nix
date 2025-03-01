{pkgs, ...}: {
  home.packages = with pkgs; [
    unstable.aerospace
  ];
}

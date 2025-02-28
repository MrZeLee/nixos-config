{
  pkgs,
  lib,
  ...
}: {
  environment = {
    systemPackages = with pkgs;
      []
      ++ lib.optionals pkgs.stdenv.isLinux [
        pinentry-all
      ];
    sessionVariables = lib.mkIf pkgs.stdenv.isLinux {
        PINENTRY_PROGRAM = "${pkgs.pinentry-all}/bin/pinentry";
      };
  };
}

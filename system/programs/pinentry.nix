{
  pkgs,
  lib,
  isLinux,
  ...
}: {
  environment = {
    systemPackages = with pkgs;
      []
      ++ lib.optionals isLinux [
        pinentry-all
      ];
    sessionVariables = lib.mkIf isLinux {
        PINENTRY_PROGRAM = "${pkgs.pinentry-all}/bin/pinentry";
      };
  };
}

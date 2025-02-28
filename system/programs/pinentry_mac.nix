{
  pkgs,
  lib,
  ...
}: {
  environment = {
    systemPackages = with pkgs;
      []
      ++ lib.optionals pkgs.stdenv.isDarwin [
        pinentry_mac
      ];
    variables = lib.mkIf pkgs.stdenv.isDarwin {
        PINENTRY_PROGRAM = "${pkgs.pinentry_mac}/bin/pinentry-mac";
      };
  };
}

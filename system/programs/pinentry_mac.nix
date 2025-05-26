{
  pkgs,
  lib,
  isDarwin,
  ...
}: let
  myPinentryMac = pkgs.pinentry_mac.overrideAttrs (old: {
    installPhase =
      (old.installPhase or "")
      + ''
        # Create a symlink so that 'pinentry' is available
        ln -s $out/bin/pinentry-mac $out/bin/pinentry
      '';
  });
in {
  environment = {
    systemPackages =
      []
      ++ lib.optionals isDarwin [
        myPinentryMac
      ];
    variables = lib.mkIf isDarwin {
      PINENTRY_PROGRAM = "${pkgs.pinentry_mac}/bin/pinentry-mac";
    };
  };
}

{pkgs, ...}: {
  home.packages = with pkgs;
    [
      signal-desktop
      telegram-desktop
      zoom-us
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      caprine # Facebook Messenger
      whatsapp-for-linux
      vesktop # Discord
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
    ];
}

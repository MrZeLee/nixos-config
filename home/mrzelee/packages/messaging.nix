{pkgs, isDarwin, isLinux, ...}: {
  home.packages = with pkgs;
    [
      signal-desktop
      telegram-desktop
      zoom-us
    ]
    ++ lib.optionals isLinux [
      caprine # Facebook Messenger
      whatsapp-for-linux
      vesktop # Discord
    ]
    ++ lib.optionals isDarwin [
    ];
}

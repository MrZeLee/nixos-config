{pkgs, isDarwin, isLinux, ...}: {
  home.packages = with pkgs;
    [
      signal-desktop-bin
      telegram-desktop
      zoom-us
    ]
    ++ lib.optionals isLinux [
      caprine # Facebook Messenger
      # wasistlos # WhatsApp in browser
      vesktop # Discord
    ]
    ++ lib.optionals isDarwin [
    ];
}

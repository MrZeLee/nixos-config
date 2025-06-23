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
      teams-for-linux
    ]
    ++ lib.optionals isDarwin [
      teams
    ];
}

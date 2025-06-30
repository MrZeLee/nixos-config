{pkgs, isDarwin, isLinux, isX86_64, ...}: {
  home.packages = with pkgs;
    [
      signal-desktop-bin
      telegram-desktop
    ]
    ++ lib.optionals isLinux [
      caprine # Facebook Messenger
      # wasistlos # WhatsApp in browser
      vesktop # Discord
      teams-for-linux
    ]
    ++ lib.optionals (isLinux && isX86_64) [
      zoom-us
    ]
    ++ lib.optionals isDarwin [
      teams
      zoom-us
    ];
}

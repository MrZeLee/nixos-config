{
  pkgs,
  config,
  isDarwin,
  isLinux,
  isX86_64,
  ...
}:
let
  wrapGL = config.lib.nixGL.wrap;
in
{
  home.packages =
    with pkgs;
    [
      (wrapGL signal-desktop)
      (wrapGL telegram-desktop)
    ]
    ++ lib.optionals isLinux [
      (wrapGL caprine) # Facebook Messenger
      # wasistlos # WhatsApp in browser
      (wrapGL vesktop) # Discord
      (wrapGL teams-for-linux)
    ]
    ++ lib.optionals (isLinux && isX86_64) [
      (wrapGL zoom-us)
    ]
    ++ lib.optionals isDarwin [
      teams
      zoom-us
    ];
}

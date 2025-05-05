{pkgs, ...}: {
  # Darwin-specific module configurations
  environment.systemPackages = with pkgs; [
    unstable.mas # Mac App Store CLI
  ];

  # Homebrew needs to be installed on its own!
  homebrew = {
    enable = true;
    casks = [
      "adobe-acrobat-reader"
      "adobe-digital-editions"
      "amitv87-pip"
      "alfred"
      "authy"
      "bartender"
      # "calibre"
      "cheatsheet"
      "chromium"
      "cloudflare-warp"
      "discord"
      "displaylink"
      "docker"
      "drawio"
      "firefox"
      "github"
      "gnucash"
      "google-chrome"
      "google-cloud-sdk"
      "google-drive"
      "iina"
      "karabiner-elements"
      "keyboardcleantool"
      "kobo"
      {
        name = "librewolf";
        args = {
          no_quarantine = true;
        };
      }
      "mactex-no-gui"
      "mendeley"
      "messenger"
      "mimestream"
      "obs"
      "ollama"
      "onionshare"
      "opera"
      "openemu"
      "pdf-expert"
      "plex"
      "private-internet-access"
      "raspberry-pi-imager"
      "shottr"
      "skim"
      "steam"
      "stremio"
      "temurin"
      "termius"
      "tor-browser"
      "tunnelblick"
      "typora"
      "whatsapp"
      "vlc"
    ];
    brews = [
      "blueutil"
      "mpg123"
      "monero"
      "tor"
      "wireguard-tools"
    ];
    taps = [
      "nikitabobko/tap"
      "FelixKratz/formulae"
      "homebrew/services"
    ];
    masApps = {
      "Print to PDF" = 1639234272;
      "Webcam Settings" = 533696630;
      "Be Focused Pro" = 961632517;
      "Xcode" = 497799835;
      "Chrono Plus" = 946047238;
      "Focus Matrix" = 1087284172;
      "The Unarchiver" = 425424353;
      # removed temp to test BetterScreen
      # "LG Screen Manager" = 1142051783;
      "WireGuard" = 1451685025;
    };
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
    };
  };
}

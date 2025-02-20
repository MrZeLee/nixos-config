{pkgs, ...}: {
  home.packages = with pkgs; [
    vesktop # Discord
    whatsapp-for-linux
    caprine # Facebook Messenger
    signal-desktop
    telegram-desktop
    zoom-us
  ];
}

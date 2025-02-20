{pkgs, ...}: {
  home.packages = with pkgs; [
    # Security
    keepassxc
    gnupg
    pass
    tor
    tor-browser
    pinentry-all
    seahorse

    # System
    pciutils
    usbutils
    lshw

    # Network
    nmap
    netcat
    wget
    curl

    # Misc
    qbittorrent
  ];
}

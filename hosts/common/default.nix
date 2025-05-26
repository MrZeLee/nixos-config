{pkgs, ...}: {
  # Common system configuration
  time.timeZone = "Europe/Lisbon";

  # Common locale settings
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "pt_PT.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
      LC_MESSAGES = "en_US.UTF-8";
      LC_IDENTIFICATION = "pt_PT.UTF-8";
      LC_CTYPE = "pt_PT.UTF-8";
      LC_COLLATE = "pt_PT.UTF-8";
      LC_TIME = "pt_PT.UTF-8";
      LC_NUMERIC = "pt_PT.UTF-8";
      LC_MONETARY = "pt_PT.UTF-8";
      LC_PAPER = "pt_PT.UTF-8";
      LC_MEASUREMENT = "pt_PT.UTF-8";
      LC_NAME = "pt_PT.UTF-8";
      LC_ADDRESS = "pt_PT.UTF-8";
      LC_TELEPHONE = "pt_PT.UTF-8";
    };
  };

  environment.systemPackages = [
    pkgs.curl
    pkgs.vim
    pkgs.neovim
    pkgs.git
    pkgs.tmux
    pkgs.zsh
  ];
  environment.variables.EDITOR = "nvim";
}

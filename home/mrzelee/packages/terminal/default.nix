{
  pkgs,
  osConfig,
  ...
}: {
  imports = [
    ./yazi
  ];

  home.packages = with pkgs;
    [
      wezterm
      kitty
      tmux
      zsh
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      # Terminal utilities
      (
        if osConfig.hardware.nvidia.modesetting.enable
        then btop.override {cudaSupport = true;}
        else btop
      )
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      btop
    ];
}

{
  pkgs,
  osConfig,
  isLinux,
  isDarwin,
  ...
}: {
  imports = [
    ./yazi
  ];

  home.packages = with pkgs;
    [
      wezterm
      ghostty
      kitty
      tmux
      zsh
    ]
    ++ lib.optionals isLinux [
      # Terminal utilities
      (
        if osConfig.hardware.nvidia.modesetting.enable
        then btop.override {cudaSupport = true;}
        else btop
      )
    ]
    ++ lib.optionals isDarwin [
      btop
    ];
}

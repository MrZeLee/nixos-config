{
  pkgs,
  config,
  osConfig ? null,
  isLinux,
  isDarwin,
  ...
}:
let
  wrapGL = config.lib.nixGL.wrap; # no-op quando nixGL não está configurado (NixOS/darwin)
  # ponytail: sem osConfig (home-manager standalone) assume-se sem nvidia
  nvidia = osConfig.hardware.nvidia.modesetting.enable or false;
in
{
  imports = [
    ./yazi
  ];

  home.packages =
    with pkgs;
    [
      (wrapGL wezterm)
      (wrapGL ghostty)
      (wrapGL kitty)
      tmux
      zsh
    ]
    ++ lib.optionals isLinux [
      # Terminal utilities
      (if nvidia then btop.override { cudaSupport = true; } else btop)
    ]
    ++ lib.optionals isDarwin [
      btop
    ];
}

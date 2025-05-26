{
  pkgs,
  lib,
  isLinux,
  isDarwin,
  ...
}: {
  home.packages = with pkgs;
    [
    ]
    ++ lib.optionals isLinux [
    ]
    ++ lib.optionals isDarwin [
    ];
}

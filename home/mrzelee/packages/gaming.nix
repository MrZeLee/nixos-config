{
  pkgs,
  isX86_64,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      mangohud
    ]
    ++ lib.optionals isX86_64 [
      optcg-sim
    ];
}

{inputs, isAarch64, isX86_64, lib, ...}: {
  imports = [
    ./audio.nix
    ./bluetooth.nix
  ] ++ lib.optionals isAarch64 [
    ./opengl_aarch64.nix
  ]
  ++ lib.optionals isX86_64 [
    ./opengl.nix
    ./nvidia.nix
  ];
}

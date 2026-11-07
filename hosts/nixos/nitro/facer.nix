# RGB keyboard backlight for the Nitro AN515-58. Mainline acer_wmi has no
# keyboard-light support; facer is a patched acer_wmi that adds it, so the
# stock module must stay unloaded. Usage: `facer_rgb -m 0 -z 1 -cR 255 -cG 0 -cB 0`.
{ config, pkgs, ... }:
let
  inherit (config.boot.kernelPackages) kernel kernelModuleMakeFlags;
  src = pkgs.fetchFromGitHub {
    owner = "JafarAkhondali";
    repo = "acer-predator-turbo-and-rgb-keyboard-linux-module";
    rev = "4aee692ffb043999b0e18b4f53d1a8d68f83d253";
    hash = "sha256-XyLwSNB/dvykYGmB0C0vV2sJaGX09dQ9chygVtly1lM=";
  };
  facer = pkgs.stdenv.mkDerivation {
    pname = "facer";
    version = "0-unstable-2026-10-19";
    inherit src;
    nativeBuildInputs = kernel.moduleBuildDependencies;
    makeFlags = kernelModuleMakeFlags ++ [
      "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    ];
    buildFlags = [ "default" ];
    installPhase = ''
      install -Dm444 src/facer.ko $out/lib/modules/${kernel.modDirVersion}/extra/facer.ko
    '';
  };
  facer_rgb = pkgs.writers.writePython3Bin "facer_rgb" {
    flakeIgnore = [
      "E"
      "W"
    ];
  } (builtins.readFile "${src}/facer_rgb.py");
in
{
  boot.extraModulePackages = [ facer ];
  boot.kernelModules = [ "facer" ];
  boot.blacklistedKernelModules = [ "acer_wmi" ];
  # facer creates /dev/acer-gkbbl-* root-only; let logged-in users drive the lights.
  services.udev.extraRules = ''
    KERNEL=="acer-gkbbl-*", TAG+="uaccess"
  '';
  environment.systemPackages = [ facer_rgb ];
}

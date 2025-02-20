{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  nix-gaming = inputs.nix-gaming;

  inherit (pkgs.writers) writeDash;

  hyprctl = "${lib.getExe' pkgs.hyprland "hyprctl"} -i 0";
  # powerprofilesctl = lib.getExe pkgs.power-profiles-daemon;
  notify-send = lib.getExe pkgs.libnotify;
  makoctl = lib.getExe' pkgs.mako "makoctl";
  swww = lib.getExe' swww "swww";
  jq_command = lib.getExe pkgs.jq;
  xargs = lib.getExe' pkgs.findutils "xargs";
  pgrep = lib.getExe' pkgs.procps "pgrep";
  pkill = lib.getExe' pkgs.procps "pkill";

  startScript = writeDash "gamemode-start" ''
    ${notify-send} -u low -a 'Gamemode' 'Optimizations activated'
    ${hyprctl} --batch "\
      keyword animations:enabled 0;\
      keyword decoration:shadow:enabled 0;\
      keyword decoration:blur:enabled 0;\
      keyword general:gaps_in 0;\
      keyword general:gaps_out 0;\
      keyword general:border_size 1;\
      keyword decoration:rounding 0;\
      keyword input:kb_layout us_intl_dead_grave_and_dead_tilde_LSGT;\
      keyword input:kb_options caps:none"
    ${hyprctl} devices -j | ${jq_command} -r '.mice.[] | select(.name|test("^.*touchpad.*$")) | .name' | ${xargs} -I _ ${hyprctl} keyword "device[_]:enabled" false
    if ${pgrep} -fx "swww-daemon"; then
      ${pkill} -fx "swww-daemon"
    fi
    if ${pgrep} -fx "^waybar.*"; then
      ${pkill} -fx "^waybar.*"
    fi
    ${makoctl} mode -a 'do-not-disturb'
  '';
  endScript = writeDash "gamemode-end" ''
    ${hyprctl} reload
    ${hyprctl} devices -j | ${jq_command} -r '.mice.[] | select(.name|test("^.*touchpad.*$")) | .name' | ${xargs} -I _ ${hyprctl} keyword "device[_]:enabled" true
    ${makoctl} mode -r 'do-not-disturb'
    ${notify-send} -u low -a 'Gamemode' 'Optimizations deactivated'
  '';
in {
  imports = [
    nix-gaming.nixosModules.platformOptimizations
  ];

  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        softrealtime = "auto";
        renice = 15;
      };
      custom = {
        start = startScript.outPath;
        end = endScript.outPath;
      };
    };
  };
}

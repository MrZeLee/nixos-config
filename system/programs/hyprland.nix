{
  pkgs,
  config,
  ...
}:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = pkgs.hyprland.override {
      withSystemd = false;
      debug = false;
    };
  };

  programs.hyprlock = {
    enable = true;
  };

  programs.ydotool.enable = true;

  environment = {
    systemPackages = with pkgs; [
      hyprland
      hyprlandPlugins.hy3
      hyprlandPlugins.csgo-vulkan-fix
      hyprcapture
      hypridle
      hyprpaper
      hyprlock
      wl-kbptr
      wlrctl
      ydotool

      #dependecy for hyprland scripts
      bc
    ];

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      HYPRLAND_CSGO_VULKAN_FIX = "${pkgs.hyprlandPlugins.csgo-vulkan-fix}";
      HYPRLAND_HY3 = "${pkgs.hyprlandPlugins.hy3}";
      HYPRLAND_HYPRCAPTURE = "${pkgs.hyprcapture}";
      HYPRLAND_HOST = "${config.networking.hostName}";
    };
  };
}

{
  pkgs,
  config,
  ...
}: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = pkgs.hyprland.override {
      withSystemd = false;
      debug = false;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      hyprlandPlugins.hy3
      hyprlandPlugins.csgo-vulkan-fix
      hypridle

      #dependecy for hyprland scripts
      bc
    ];

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      HYPRLAND_CSGO_VULKAN_FIX = "${pkgs.hyprlandPlugins.csgo-vulkan-fix}";
      HYPRLAND_HY3 = "${pkgs.hyprlandPlugins.hy3}";
      HYPRLAND_HOST = "${config.networking.hostName}";
    };
  };
}

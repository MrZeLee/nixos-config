{pkgs, ...}: {
  services = {
    xserver = {
      enable = true;
      # Load nvidia driver for Xorg and Wayland
      videoDrivers = ["nvidia"];
      xkb = {
        layout = "us";
        variant = "intl";
        model = "pc105";
      };
    };

    libinput = {
      mouse.accelProfile = "flat";
      touchpad.accelProfile = "flat";
    };

    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        package = pkgs.kdePackages.sddm;
        theme = "catppuccin-mocha";
      };
      defaultSession = "hyprland";
    };
  };

  environment.systemPackages = with pkgs; [
    (pkgs.catppuccin-sddm.override {
      flavor = "mocha";
    })
  ];
}

{
  pkgs,
  config,
  ...
}: {
  boot = {
    bootspec.enableValidation = true;

    consoleLogLevel = 0;
    initrd = {
      verbose = false;
      kernelModules = ["i915"];
      systemd.enable = true;
      supportedFilesystems = [
        "ext4"
        "ntfs"
      ];
    };
    plymouth.enable = true;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 2; # Keep only the last two configurations
      };
    };
    kernelParams = [
      # General Performance Optimization
      "intel_pstate=active" # Ensures the Intel-specific CPU frequency scaling driver is used for better performance
      "iommu=pt" # Enables IOMMU in pass-through mode, reducing virtualization overhead and ensuring optimal PCIe device performance.

      # disable the boot lines
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "i915.fastboot=1"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];

    # clear tmp on boot
    tmp.cleanOnBoot = true;
  };
}

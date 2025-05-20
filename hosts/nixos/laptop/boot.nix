{
  ...
}: {
 boot = {
    bootspec.enableValidation = true;

    consoleLogLevel = 0;
    initrd = {
      verbose = false;
      kernelModules = ["i915"];
      systemd.enable = true;
    };
    plymouth.enable = true;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # To add the keys to the TPM2 use command: sudo systemd-cryptenroll
    # --tpm2-device=auto /dev/...

    initrd.luks.devices."luks-c8e08ff0-43a6-451c-a9f8-c21bc82d14f3".device = "/dev/disk/by-uuid/c8e08ff0-43a6-451c-a9f8-c21bc82d14f3";

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

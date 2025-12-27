{
  lib,
  ...
}: {
 boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = false;

    # For ` to < and ~ to > (for those with US keyboards)
    extraModprobeConfig = ''
      options hid_apple iso_layout=0
    '';
  
    # clear tmp on boot
    tmp.cleanOnBoot = true;

    # Kernel parameters: resume support, ACPI tweaks, lid init state,
    # and force Apple-specific cpuidle driver (WFI/WFE hack) over PSCI
    kernelParams = lib.mkForce [
      "resume=/dev/disk/by-label/swap"
      "acpi_osi=Linux"
      "acpi_backlight=video"
      "button.lid_init_state=open"
      # Use the Apple cpuidle driver for proper WFI/WFE idle on Apple Silicon
      "cpuidle.driver=apple"
      # set your regional domain for wifi
      "cfg80211.ieee80211_regdom=PT"
    ];
  };

  # Hibernation support: suspend-to-disk via initrd resume hook
  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];
  boot.resumeDevice = "/dev/disk/by-label/swap";

}

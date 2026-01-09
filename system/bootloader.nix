{...}: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable Magic SysRq keys for kernel debugging and emergency operations
  boot.kernel.sysctl."kernel.sysrq" = 1;
}

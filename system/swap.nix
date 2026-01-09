{lib, ...}: {
  # ============================
  # ZRAM Swap Configuration
  # ============================

  # Enable ZRAM swap (compressed RAM blocks as swap)
  zramSwap.enable = true;

  # Use 50% of RAM for ZRAM (4GB on 8GB system)
  # With compression (2:1 to 3:1) = ~8-12GB effective swap
  zramSwap.memoryPercent = 50;

  # zstd provides the best compression/speed ratio for modern CPUs
  zramSwap.algorithm = "zstd";

  # Higher priority than any physical swap devices
  zramSwap.priority = 100;

  # ============================
  # Memory Management Tuning
  # ============================

  # More aggressive than default (60), but safe with fast ZRAM swap
  # Allows system to swap out idle pages more eagerly
  boot.kernel.sysctl."vm.swappiness" = 70;

  # Keep more file cache for better desktop responsiveness
  # Lower than default (100) = less aggressive reclaim of file cache
  boot.kernel.sysctl."vm.vfs_cache_pressure" = 50;
}

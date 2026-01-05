{...}: {
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # ============================================================================
  # POWER MANAGEMENT - Disable GNOME's Power Daemon
  # ============================================================================
  # GNOME's power-profiles-daemon would override our custom logind lid settings
  # By disabling it, we ensure our custom behavior is respected:
  # - No sleep on lid close (handled by systemd-logind in system.nix)
  # - No sleep from inactivity (handled by systemd-logind in system.nix)
  # - Screen control via custom lid-screen-handler service (in system.nix)
  services.power-profiles-daemon.enable = false;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable flatpak
  services.flatpak.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
}

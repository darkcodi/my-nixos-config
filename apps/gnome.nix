{...}: {
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # ============================================================================
  # POWER MANAGEMENT - Disable GNOME's Power Daemon
  # ============================================================================
  # GNOME's power-profiles-daemon and gsd-power would override our logind settings
  # By disabling them, we ensure our custom behavior is respected:
  # - No sleep on lid close (handled by systemd-logind in system.nix)
  # - No sleep from inactivity (handled by systemd-logind in system.nix)
  # - Screen control via custom lid-screen-handler service (in system.nix)

  # Disable GNOME's power profile daemon
  services.power-profiles-daemon.enable = false;

  # Disable GNOME Settings Daemon Power plugin (gsd-power) for user sessions
  # CRITICAL: Must disable the systemd user service that launches gsd-power
  # gsd-power has its own sleep timers that work independently of systemd-logind
  systemd.user.services."org.gnome.SettingsDaemon.Power".enable = false;
  systemd.user.targets."org.gnome.SettingsDaemon.Power".enable = false;

  # Set gsettings to ensure GNOME UI respects the disabled state
  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.settings-daemon.plugins.power]
    active=false
    sleep-inactive-ac-type='nothing'
    sleep-inactive-ac-timeout=0
    sleep-inactive-battery-type='nothing'
    sleep-inactive-battery-timeout=0

    [org.gnome.desktop.session]
    idle-delay=0
  '';

  # Disable gsd-power for GDM greeter session (the real culprit!)
  # GDM runs its own gnome-settings-daemon that can trigger suspend independently
  # We override GDM's service to disable the power plugin
  services.displayManager.gdm.settings = {
    "org/gnome/settings-daemon/plugins/power" = {
      active = false;
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-ac-timeout = 0;
      sleep-inactive-battery-type = "nothing";
      sleep-inactive-battery-timeout = 0;
    };
  };

  # Set GNOME_SETTINGS_DAEMON_PLUGINS environment variable globally
  # This prevents gsd-power from loading in both GDM and user sessions
  environment.sessionVariables.GNOME_SETTINGS_DAEMON_PLUGINS = "a11y-settings:clipboard:color:cursor:date:dummy:housekeeping:keyboard:media-keys:mouse:screenshooter:sound:usb-protection:xsettings:smartcard:wacom";

  # Additional safeguard: Override GDM systemd service to explicitly disable gsd-power
  systemd.services."gdm" = {
    environment.GNOME_SETTINGS_DAEMON_PLUGINS = "a11y-settings:clipboard:color:cursor:date:dummy:housekeeping:keyboard:media-keys:mouse:screenshooter:sound:usb-protection:xsettings:smartcard:wacom";
  };

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

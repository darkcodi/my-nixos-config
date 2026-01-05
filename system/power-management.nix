{ pkgs, username, ... }: {
  # ============================================================================
  # POWER MANAGEMENT - Prevent Sleep & Hibernate
  # ============================================================================
  # System behavior: Never sleep from lid close OR inactivity (AC or battery)
  # - Lid close: Screen turns off, system stays running
  # - Inactivity: No automatic sleep ever
  # - Background processes continue uninterrupted (downloads, servers, etc.)

  services.logind = {
    # Lid close behavior - system NEVER sleeps when closing lid
    lidSwitch = "ignore"; # On battery: ignore lid close (don't sleep)
    lidSwitchExternalPower = "ignore"; # On AC power: ignore lid close (don't sleep)
    lidSwitchDocked = "ignore"; # When docked: ignore lid close (don't sleep)

    # Inactivity behavior - system NEVER sleeps from being idle
    settings.Login = {
      IdleAction = "ignore"; # Don't sleep when inactive
      IdleActionSec = 0; # Disable idle timer completely (0 = disabled)
    };
  };

  # ============================================================================
  # SCREEN MANAGEMENT - Turn Off Display on Lid Close
  # ============================================================================
  # Custom systemd service that monitors laptop lid state and controls display
  # - When lid closes: Turn off screen (system keeps running)
  # - When lid opens: Turn on screen
  # - Uses systemd-logind monitoring (more reliable than polling ACPI)

  systemd.services.lid-screen-handler = {
    description = "Turn off screen when lid is closed";
    after = ["graphical.target" "display-manager.service"];
    wantedBy = ["graphical.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = pkgs.writeShellScript "lid-screen-handler" ''
        # X11 display environment variables for xset commands
        export DISPLAY=:0
        export XAUTHORITY=/run/user/1000/gdm/Xauthority

        # Monitor systemd-logind for lid state changes via dbus
        # This is more reliable than polling ACPI files
        ${pkgs.dbus}/bin/dbus-monitor --system "interface='org.freedesktop.login1.Manager',member='PrepareForSleep'" 2>/dev/null | \
        while read -r line; do
          # Check if system is about to sleep (we've blocked sleep, but this indicates lid close)
          if echo "$line" | grep -q "boolean true"; then
            # Lid likely closed or sleep requested - turn off screen
            ${pkgs.xorg.xset}/bin/xset dpms force off 2>/dev/null || true
          elif echo "$line" | grep -q "boolean false"; then
            # System resuming or lid opened - turn on screen
            ${pkgs.xorg.xset}/bin/xset dpms force on 2>/dev/null || true
          fi
        done &

        # Initial state: check current lid state and set screen accordingly
        # Use loginctl to check if lid is closed
        LID_CLOSED=$(${pkgs.systemd}/bin/loginctl show-session $(loginctl | grep ${username} | head -1 | awk '{print $1}') -p LidClosed 2>/dev/null | cut -d= -f2)

        if [ "$LID_CLOSED" = "yes" ]; then
          ${pkgs.xorg.xset}/bin/xset dpms force off 2>/dev/null || true
        else
          ${pkgs.xorg.xset}/bin/xset dpms force on 2>/dev/null || true
        fi

        # Keep script running so systemd doesn't restart it
        wait
      '';
      Restart = "always"; # Restart service if it crashes
      RestartSec = "5s"; # Wait 5 seconds before restarting
      User = username; # Run as user (not root) for X11 access
    };
  };

  # ============================================================================
  # SCREEN BLANKING - Disable Automatic Screen Power Saving
  # ============================================================================
  # Prevent X11 from automatically turning off screen due to inactivity
  # - Screen only turns off when lid is closed (handled by service above)
  # - Screen stays on indefinitely when lid is open

  services.xserver.displayManager.sessionCommands = ''
    xset s off        # Disable X11 screensaver (no timeout)
    xset -dpms        # Disable DPMS (Display Power Management Signaling)
    xset s noblank    # Prevent screen from blanking
  '';
}

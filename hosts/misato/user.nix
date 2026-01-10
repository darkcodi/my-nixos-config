{pkgs, ...}: {
  imports = [
    ../../apps/base-packages.nix
    ../../apps/git.nix
    ../../apps/firefox.nix
    ../../apps/zsh.nix
    ../../apps/direnv.nix
    ../../apps/claude-code.nix
    ../../apps/rust.nix
    ../../apps/cargo.nix
    ../../apps/nodejs.nix
    ../../apps/openspec.nix
    ../../apps/python.nix
    ../../apps/rjd.nix
    ../../apps/ffcv.nix
    ../../apps/aliases.nix
    ../../apps/rustrover.nix
    ../../secrets/user-decrypt.nix
  ];

  # Emergency zsh fallback configuration
  # If home-manager breaks, run: source ~/.zsh-fallback
  home.file.".zsh-fallback".text = ''
    # Emergency zsh fallback if home-manager breaks
    # Source this manually: source ~/.zsh-fallback

    echo "⚠️  Using emergency zsh fallback"
    echo "Home-manager appears to be broken. Basic shell only."
    echo ""

    # Basic PATH
    export PATH=$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:$PATH

    # Basic aliases
    alias ll='ls -la'
    alias la='ls -A'
    alias l='ls -CF'
    alias nix-rebuild='sudo nixos-rebuild switch --flake ~/my-nixos-config#misato'

    # Diagnostic info
    echo "Home-manager status:"
    systemctl --user is-active home-manager-darkcodi.service 2>/dev/null && echo "  ✅ Service running" || echo "  ❌ Service failed"
    echo ""
    echo "To rebuild and fix:"
    echo "  cd ~/my-nixos-config"
    echo "  sudo nixos-rebuild switch --flake .#misato"
    echo ""
    echo "To view logs:"
    echo "  journalctl --user -u home-manager-darkcodi.service -b"
  '';

  # Add failure detection to zsh init
  programs.zsh.initContent = ''
    # Check if home-manager is broken
    if ! systemctl --user is-active home-manager-darkcodi.service >/dev/null 2>&1; then
      echo ""
      echo "⚠️  WARNING: home-manager service is not running!"
      echo "   Run: journalctl --user -u home-manager-darkcodi.service -b"
      echo "   To rebuild: cd ~/my-nixos-config && sudo nixos-rebuild switch --flake .#misato"
      echo ""
    fi
  '';
}

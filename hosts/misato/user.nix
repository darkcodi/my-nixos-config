{...}: {
  imports = [
    ../../apps/base-packages.nix
    ../../apps/git.nix
    ../../apps/firefox.nix
    ../../apps/default-apps.nix
    ../../apps/zsh.nix
    ../../apps/direnv.nix
    ../../apps/claude-code.nix
    ../../apps/rust.nix
    ../../apps/rjd.nix
    ../../secrets/user-decrypt.nix
  ];

  # Host-specific aliases
  programs.zsh.shellAliases = {
    ll = "ls -alh";
    ga = "git add";
    gaa = "git add .";
    gc = "git commit";
    gcm = "git commit -m";
    gca = "git commit --amend";
    gp = "git push";
    gpf = "git push --force";
    gd = "git diff";
    gds = "git diff --staged";
    gda = "git diff -a";
    gdsa = "git diff --staged -a";
    gl = "git log";
    gs = "git status";
    rebuild-switch = "sudo nixos-rebuild switch --flake .#misato";
    rebuild-test = "sudo nixos-rebuild test --fast-switch --flake .#misato";
    rebuild-check = "nix flake check";
    rebuild-rollback = "sudo nixos-rebuild --rollback switch --flake .#misato";
  };
}

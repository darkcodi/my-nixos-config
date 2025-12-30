{...}: {
  programs.zsh.shellAliases = {
    # Basic ls aliases
    ll = "ls -alh";

    # Git aliases
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

    # NixOS rebuild aliases
    rebuild-switch = "sudo nixos-rebuild switch --flake .#misato";
    rebuild-test = "sudo nixos-rebuild test --fast-switch --flake .#misato";
    rebuild-check = "nix flake check";
    rebuild-rollback = "sudo nixos-rebuild --rollback switch --flake .#misato";

    # Cargo aliases
    cf = "cargo fmt";
    cb = "cargo build";
    ct = "cargo test";
    cl = "cargo clippy";
    cr = "cargo run";
    cbr = "cargo build --release";
    crr = "cargo run --release";
    cch = "cargo check";
    cw = "cargo watch";
    cdoc = "cargo doc";
    ca = "cargo add";
    crm = "cargo remove";
    cup = "cargo update";
    ccl = "cargo clean";
  };
}

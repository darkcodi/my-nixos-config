{pkgs, ...}: let
  src = pkgs.fetchgit {
    url = "https://github.com/darkcodi/rjd.git";
    rev = "v1.2.1";
    sha256 = "sha256-vNYjtdaxriauBAq4zx1yckq/S7QOcxuHVXBDWN5z+ss=";
  };
  rjd = pkgs.rustPlatform.buildRustPackage {
    pname = "rjd";
    version = "1.2.1";
    inherit src;
    cargoLock.lockFile = "${src}/Cargo.lock";
    cargoHash = "";
  };
in {
  home.packages = with pkgs; [
    rjd
  ];
}

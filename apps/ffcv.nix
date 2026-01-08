{pkgs, ...}: let
  src = pkgs.fetchgit {
    url = "https://github.com/darkcodi/ffcv.git";
    rev = "v1.0.2";
    sha256 = "sha256-oJP3bhm6UQXisQgGZx/7Hs52hz6Ypss0grapvUboaJE=";
  };

  ffcv = pkgs.rustPlatform.buildRustPackage {
    pname = "ffcv";
    version = "1.0.2";
    inherit src;

    cargoLock.lockFile = "${src}/Cargo.lock";
    cargoHash = "";
  };
in {
  home.packages = with pkgs; [
    ffcv
  ];
}

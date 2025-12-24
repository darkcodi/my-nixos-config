{pkgs, ...}: let
  src = pkgs.fetchgit {
    url = "https://github.com/darkcodi/rjd.git";
    rev = "v1.0.0";
    sha256 = "sha256-zwSCBLe7BhSkheEYe3DHBniPo7uPFEtb7+EzMVV+ye0=";
  };
  rjd = pkgs.rustPlatform.buildRustPackage {
    pname = "rjd";
    version = "1.0.0";
    inherit src;
    cargoLock.lockFile = "${src}/Cargo.lock";
    cargoHash = "";
  };
in {
  home.packages = with pkgs; [
    rjd
  ];
}

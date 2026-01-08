{pkgs, ...}: let
  openspec = pkgs.buildNpmPackage {
    pname = "openspec";
    version = "0.18.0";

    src = pkgs.fetchFromGitHub {
      owner = "Fission-AI";
      repo = "OpenSpec";
      tag = "v0.18.0";
      hash = "sha256-OvD9i1MN5U9YqL+JmLETessvatI8Eu2Rwze3ONJqZXc=";
    };

    # Use the pre-generated package-lock.json
    postPatch = ''
      cp ${./openspec-package-lock.json} package-lock.json
    '';

    npmDepsHash = "sha256-PgPbFiCexxlTd/p+lzw1YjMbXKJqAWYK4mOdrH0glM8=";

    # Skip npm install - dependencies are already installed by npmConfigHook
    # and the prepare script requires pnpm which we don't have
    dontNpmInstall = true;

    # Manually install the built files
    installPhase = ''
      runHook preInstall

      # Create output directories
      mkdir -p $out/lib/node_modules/@fission-ai/openspec
      mkdir -p $out/bin

      # Copy package files (dist, bin, schemas, package.json)
      cp -r dist bin schemas package.json $out/lib/node_modules/@fission-ai/openspec/

      # Copy node_modules (runtime dependencies only - already built)
      cp -r node_modules $out/lib/node_modules/@fission-ai/openspec/

      # Create symlink to the binary
      ln -sf $out/lib/node_modules/@fission-ai/openspec/bin/openspec.js $out/bin/openspec

      runHook postInstall
    '';

    meta = {
      description = "AI-native system for spec-driven development";
      homepage = "https://github.com/Fission-AI/OpenSpec";
      license = pkgs.lib.licenses.mit;
      maintainers = [];
    };
  };
in {
  home.packages = with pkgs; [
    openspec
  ];
}

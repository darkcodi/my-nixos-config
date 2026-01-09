{config, ...}: {
  home.activation.cargoCredentials = config.lib.dag.entryAfter ["writeBoundary"] ''
      mkdir -p ~/.cargo
      TOKEN=$(cat ${config.age.secrets.cratesIoApiToken.path})
      cat > ~/.cargo/credentials.toml << EOF
    [registry]
    token = "$TOKEN"
    EOF
      chmod 600 ~/.cargo/credentials.toml
  '';
}

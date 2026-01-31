{pkgs, ...}: {
  home.packages = with pkgs; [
    mosquitto # MQTT broker and client tools
  ];
}

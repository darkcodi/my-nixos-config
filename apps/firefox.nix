{pkgs, ...}: {
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        "browser.startup.page" = 3; # restore previous session
        "browser.theme.dark.activetab" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      extensions = with pkgs.firefox-addons; [
        ublock-origin
      ];
    };
  };
}

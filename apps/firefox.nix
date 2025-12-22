{...}: {
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      name = "darkcodi";
      settings = {
        "browser.startup.page" = 3; # restore previous session
        "browser.theme.dark.activetab" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
    };
  };
}

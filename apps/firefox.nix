{...}: {
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        "browser.startup.page" = 3; # restore previous session
      };
    };
  };
}

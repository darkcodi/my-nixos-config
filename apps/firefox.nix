{...}: {
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      name = "darkcodi";
      settings = {
        "app.normandy.first_run" = false;

        "browser.bookmarks.addedImportButton" = true;
        "browser.bookmarks.restore_default_bookmarks" = false;
        "browser.contentblocking.category" = "strict";
        "browser.engagement.fxa-toolbar-menu-button.has-used" = true;
        "browser.laterrun.enabled" = true;
        "browser.newtabpage.activity-stream.newtabWallpapers.wallpaper" = "dark-blue"; # set newtab wallpaper
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false; # disable news on newtab page
        "browser.newtabpage.activity-stream.feeds.topsites" = false; # disable sites recommendations on newtab page
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false; # disable ads
        "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false; # disable ads
        "browser.newtabpage.activity-stream.showSponsored" = false; # disable ads
        "browser.newtabpage.activity-stream.showWeather" = false; # remove weather widget from newtab page
        "browser.policies.applied" = true;
        "browser.shell.didSkipDefaultBrowserCheckOnFirstRun" = true;
        "browser.startup.page" = 3; # restore previous session
        "browser.tabs.groups.smart.userEnabled" = false; # disable ai tag suggestion
        "browser.toolbarbuttons.introduced.sidebar-button" = true;
        "browser.theme.dark.activetab" = true;
        "browser.urlbar.placeholderName" = "DuckDuckGo"; # set DDG as default search engine
        "browser.urlbar.placeholderName.private" = "DuckDuckGo"; # set DDG as default search engine
        "browser.urlbar.suggest.quicksuggest.all" = false; # disable FF (and partners) suggestions

        "dom.forms.autocomplete.formautofill" = true;

        "distribution.nixos.bookmarksProcessed" = true;

        "extensions.activeThemeID" = "default-theme@mozilla.org";

        "identity.fxaccounts.toolbar.syncSetup.panelAccessed" = true;

        "network.http.referer.disallowCrossSiteRelaxingDefault.top_navigation" = true;

        "privacy.annotate_channels.strict_list.enabled" = true;
        "privacy.bounceTrackingProtection.mode" = 1;
        "privacy.fingerprintingProtection" = true;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.globalprivacycontrol.was_ever_enabled" = true;
        "privacy.query_stripping.enabled" = true;
        "privacy.query_stripping.enabled.pbmode" = true;
        "privacy.trackingprotection.allow_list.hasUserInteractedWithETPSettings" = true;
        "privacy.trackingprotection.consentmanager.skip.pbmode.enabled" = false;
        "privacy.trackingprotection.emailtracking.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;

        "sidebar.main.tools" = "syncedtabs,history,bookmarks";
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.verticalTabs.dragToPinPromo.dismissed" = true;

        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;

        "trailhead.firstrun.didSeeAboutWelcome" = true;
      };
    };
  };
}

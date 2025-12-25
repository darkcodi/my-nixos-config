{...}: {
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      name = "darkcodi";
      settings = {
        # ====================
        # First Run / Onboarding
        # ====================
        "app.normandy.first_run" = false;
        "browser.aboutwelcome.didSeeFinalScreen" = true;
        "browser.laterrun.enabled" = true;
        "browser.policies.applied" = true;
        "browser.shell.didSkipDefaultBrowserCheckOnFirstRun" = true;
        "trailhead.firstrun.didSeeAboutWelcome" = true;

        # ====================
        # New Tab Page
        # ====================
        "browser.newtabpage.activity-stream.newtabWallpapers.wallpaper" = "dark-blue"; # set newtab wallpaper
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false; # disable news on newtab page
        "browser.newtabpage.activity-stream.feeds.topsites" = false; # disable sites recommendations on newtab page
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false; # disable ads
        "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false; # disable ads
        "browser.newtabpage.activity-stream.showSponsored" = false; # disable ads
        "browser.newtabpage.activity-stream.showWeather" = false; # remove weather widget from newtab page

        # ====================
        # Browser Behavior
        # ====================
        "browser.bookmarks.addedImportButton" = true;
        "browser.bookmarks.restore_default_bookmarks" = false;
        "browser.contentblocking.category" = "strict";
        "browser.engagement.fxa-toolbar-menu-button.has-used" = true;
        "browser.startup.page" = 3; # restore previous session
        "browser.tabs.groups.smart.userEnabled" = false; # disable ai tag suggestion

        # ====================
        # Search Engine
        # ====================
        "browser.urlbar.placeholderName" = "DuckDuckGo"; # set DDG as default search engine
        "browser.urlbar.placeholderName.private" = "DuckDuckGo"; # set DDG as default search engine
        "browser.urlbar.suggest.quicksuggest.all" = false; # disable FF (and partners) suggestions

        # ====================
        # Telemetry
        # ====================
        "datareporting.healthreport.uploadEnabled" = false; # disable telemetry healthchecks
        "datareporting.usage.uploadEnabled" = false; # disable mozilla telemetry
        "toolkit.telemetry.reportingpolicy.firstRun" = false;

        # ====================
        # DNS & Networking
        # ====================
        "doh-rollout.disable-heuristics" = true;
        "network.http.referer.disallowCrossSiteRelaxingDefault.top_navigation" = true;
        "network.trr.mode" = 3;
        "network.trr.uri" = "https://mozilla.cloudflare-dns.com/dns-query";

        # ====================
        # Security
        # ====================
        "dom.forms.autocomplete.formautofill" = true;
        "dom.security.https_only_mode_pbm" = true;
        "dom.security.https_only_mode_ever_enabled_pbm" = true;

        # ====================
        # Extensions & Theme
        # ====================
        "distribution.nixos.bookmarksProcessed" = true;
        "extensions.activeThemeID" = "default-theme@mozilla.org";
        "extensions.formautofill.creditCards.enabled" = false; # disable payments autofill/saving
        "extensions.formautofill.addresses.enabled" = false; # disable addresses autofill/saving
        "identity.fxaccounts.toolbar.syncSetup.panelAccessed" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # ====================
        # Privacy & Tracking Protection
        # ====================
        "privacy.annotate_channels.strict_list.enabled" = true;
        "privacy.bounceTrackingProtection.mode" = 1;
        "privacy.fingerprintingProtection" = true;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.globalprivacycontrol.was_ever_enabled" = true;
        "privacy.query_stripping.enabled" = true;
        "privacy.query_stripping.enabled.pbmode" = true;
        "privacy.trackingprotection.allow_list.convenience.enabled" = false;
        "privacy.trackingprotection.allow_list.baseline.enabled" = false;
        "privacy.trackingprotection.allow_list.hasUserInteractedWithETPSettings" = true;
        "privacy.trackingprotection.consentmanager.skip.pbmode.enabled" = false;
        "privacy.trackingprotection.emailtracking.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;

        # ====================
        # Sidebar & UI
        # ====================
        "browser.theme.dark.activetab" = true;
        "browser.toolbarbuttons.introduced.sidebar-button" = true;
        "sidebar.main.tools" = "syncedtabs,history,bookmarks";
        "sidebar.notification.badge.aichat" = false;
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.verticalTabs.dragToPinPromo.dismissed" = true;

        # ====================
        # Password Management
        # ====================
        # disable password saving
        "signon.rememberSignons" = false;
        "signon.management.page.breach-alerts.enabled" = false;
        "signon.autofillForms" = false;
        "signon.firefoxRelay.feature" = "disabled";
        "signon.generation.enabled" = false;
      };
    };
  };
}

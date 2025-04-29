{pkgs, ...}: {
  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;
    preferencesStatus = "default";
    preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
      "media.rdd-fmmpeg.enabled" = true;
      "media.av1.enabled" = false;
      "widget.dmabuf.force-enabled" = true;

      "browser.preferences.defaultPerformanceSettings.enabled" = false;
      "browser.translations.automaticallyPopup" = false;
      "signon.rememberSignons" = false;
      "privacy.globalprivacycontrol.enabled" = true;
      "privacy.donottrackheader.enabled" = true;
      "datareporting.healthreport.uploadEnabled" = false;
      "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
      "network.trr.mode" = 3;
      "browser.sessionstore.restore_on_demand" = false;
    };
    policies = {
      ExtensionSettings = {
        "jid1-ZAdIEUB7XOzOJw@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/duckduckgo-for-firefox/latest.xpi";
          installation_mode = "normal_installed";
          private_browsing = true;
        };
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "normal_installed";
          private_browsing = true;
        };
        "vimium-c@gdh1995.cn" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-c/latest.xpi";
          installation_mode = "normal_installed";
          private_browsing = true;
        };
        "keepassxc-browser@keepassxc.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
          installation_mode = "normal_installed";
          private_browsing = true;
        };
        "newtab-adapter@gdh1995.cn" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/newtab-adapter/latest.xpi";
          installation_mode = "normal_installed";
          private_browsing = true;
        };
        "addon@darkreader.org" = {
          install_url =
            "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "normal_installed";
          private_browsing = true;
        };
      };
    };
  };
}

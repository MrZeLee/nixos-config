{
  programs.firefox = {
    enable = true;
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
  };
}

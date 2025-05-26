{ pkgs, lib, isLinux, isDarwin, ... }:

{
  programs.firefox = {
    enable  = true;
    package = if isDarwin then null
      else if isLinux then pkgs.librewolf
      else null;
    configPath =
      if isDarwin then "Library/Application Support/librewolf"
      else if isLinux then ".librewolf"
      else ".librewolf";

    # -------- PERFIL --------
    profiles.default = {
      id        = 0;
      isDefault = true;
      name      = "nixos";

      bookmarks = [
        {
          name = "WhatsApp";
          tags = ["whatsapp"];
          keyword = "whatsapp";
          url = "https://web.whatsapp.com";
        }
      ];

      settings = {
        # ─── Aceleração por VA-API ──────────────────────────────────────────────
        "media.ffmpeg.vaapi.enabled"   = true;
        "media.rdd-ffmpeg.enabled"     = true;
        "media.av1.enabled"            = false;
        "widget.dmabuf.force-enabled"  = true;

        # ─── Performance & UX ──────────────────────────────────────────────────
        "browser.preferences.defaultPerformanceSettings.enabled" = false;
        "browser.translations.automaticallyPopup"               = false;
        "browser.sessionstore.restore_on_demand"                = false;

        # ─── Privacidade ───────────────────────────────────────────────────────
        "signon.rememberSignons"                = false;
        "privacy.globalprivacycontrol.enabled"  = true;
        "privacy.donottrackheader.enabled"      = true;
        "datareporting.healthreport.uploadEnabled"            = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2"   = false;
        "network.trr.mode"                      = 3;

        # ─── Manter logins entre sessões ──────────────────────────────────────
        "privacy.sanitize.sanitizeOnShutdown"          = false;
        "privacy.sanitize.pending"                     = "[]";
        "privacy.clearOnShutdown_v2.cache"             = false;
        "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;

        # Desactivar desactivação automática de extensões instaladas por HM
        "extensions.autoDisableScopes" = 0;
        "browser.profiles.enabled" = true;
      };
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        darkreader
        keepassxc-browser
        vimium-c
        newtab-adapter
        video-downloadhelper
        brotab
      ];
    };
  };

  home = lib.mkMerge [
    (lib.mkIf isLinux {
      activation = {
        librewolf = lib.hm.dag.entryAfter ["writeBoundary"] ''
          ln -s ~/.mozilla/native-messaging-hosts ~/.librewolf/native-messaging-hosts || true
        '';
      };
    })

    (lib.mkIf isDarwin {
      activation = {
        librewolf = lib.hm.dag.entryAfter ["writeBoundary"] ''
          ln -s ~/Library/Application\ Support/Mozilla/NativeMessagingHosts ~/Library/Application\ Support/librewolf/NativeMessagingHosts || true
        '';
      };
    })
  ];
}

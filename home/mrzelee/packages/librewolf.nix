{ pkgs, lib, config, isLinux, isDarwin, ... }:

let
  bookmarkFile = config.programs.firefox.profiles.default.bookmarks.configFile;
in
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

      bookmarks = {
        enable = true;
        force = true;
        settings = [
          {
            name = "Bookmarks Toolbar";
            toolbar = true;
            bookmarks = [
              {
                name = "WhatsApp";
                tags = ["messages"];
                keyword = "whatsapp";
                url = "https://web.whatsapp.com";
              }
              {
                name = "Messenger";
                tags = ["messages"];
                keyword = "messenger";
                url = "https://www.messenger.com";
              }
              {
                name = "NixOS Search Packages";
                tags = ["nixos" "search"];
                keyword = "nixpkgs";
                url = "https://search.nixos.org/packages";
              }
            ];
          }
        ];
      };

      settings = {
        # ─── Aceleração por VA-API ──────────────────────────────────────────────
        "media.ffmpeg.vaapi.enabled"   = true;
        "media.rdd-ffmpeg.enabled"     = true;
        "media.av1.enabled"            = false;
        "widget.dmabuf.force-enabled"  = true;

        "browser.eme.ui.enabled"       = true;

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

        "browser.places.importBookmarksHTML" = true;
        "browser.bookmarks.file"             = bookmarkFile;

        # optional quality-of-life tweaks
        "browser.toolbars.bookmarks.visibility" = "always";  # show toolbar

        #UI
        "browser.uiCustomization.state" = "{\"placements\":{\"widget-overflow-fixed-list\":[],\"unified-extensions-area\":[\"vimium-c_gdh1995_cn-browser-action\",\"_b9db16a4-6edc-47ec-a1f4-b86292ed211d_-browser-action\"],\"nav-bar\":[\"back-button\",\"forward-button\",\"stop-reload-button\",\"customizableui-special-spring1\",\"bookmarks-menu-button\",\"screenshot-button\",\"vertical-spacer\",\"urlbar-container\",\"customizableui-special-spring2\",\"save-to-pocket-button\",\"downloads-button\",\"fxa-toolbar-menu-button\",\"ublock0_raymondhill_net-browser-action\",\"unified-extensions-button\",\"keepassxc-browser_keepassxc_org-browser-action\",\"addon_darkreader_org-browser-action\"],\"toolbar-menubar\":[\"menubar-items\"],\"TabsToolbar\":[\"tabbrowser-tabs\",\"new-tab-button\",\"alltabs-button\"],\"vertical-tabs\":[],\"PersonalToolbar\":[\"personal-bookmarks\"]},\"seen\":[\"addon_darkreader_org-browser-action\",\"keepassxc-browser_keepassxc_org-browser-action\",\"ublock0_raymondhill_net-browser-action\",\"vimium-c_gdh1995_cn-browser-action\",\"_b9db16a4-6edc-47ec-a1f4-b86292ed211d_-browser-action\",\"developer-button\",\"screenshot-button\"],\"dirtyAreaCache\":[\"unified-extensions-area\",\"nav-bar\",\"vertical-tabs\"],\"currentVersion\":22,\"newElementCount\":3}";
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
          rm -rf ~/.librewolf/native-messaging-hosts && \
          ln -s ~/.mozilla/native-messaging-hosts ~/.librewolf/native-messaging-hosts || true
        '';
      };
    })

    (lib.mkIf isDarwin {
      activation = {
        librewolf = lib.hm.dag.entryAfter ["writeBoundary"] ''
          rm -rf ~/Library/Application\ Support/librewolf/NativeMessagingHosts && \
          ln -s ~/Library/Application\ Support/Mozilla/NativeMessagingHosts ~/Library/Application\ Support/librewolf/NativeMessagingHosts || true
        '';
      };
    })
  ];
}

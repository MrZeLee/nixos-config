{pkgs, ...}: {
  # Darwin-specific host configurations
  system = {
    defaults = {
      CustomSystemPreferences = {
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
      };

      ".GlobalPreferences"."com.apple.mouse.scaling" = -1.0;

      NSGlobalDomain = {
        AppleICUForce24HourTime = true;
        AppleInterfaceStyle = "Dark";
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        AppleShowAllExtensions = true;
        AppleShowScrollBars = "WhenScrolling";
        AppleTemperatureUnit = "Celsius";
        NSDocumentSaveNewDocumentsToCloud = false;

        InitialKeyRepeat = 15;
        KeyRepeat = 3;

        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticInlinePredictionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        NSDisableAutomaticTermination = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        NSWindowShouldDragOnGesture = true;
        NSWindowResizeTime = 0.0;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;
        _HIHideMenuBar = true;
        "com.apple.keyboard.fnState" = true;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.feedback" = 0;
        "com.apple.sound.beep.volume" = 0.6065307;
        "com.apple.swipescrolldirection" = true;
        "com.apple.trackpad.enableSecondaryClick" = true;
        "com.apple.trackpad.scaling" = 1.0;
        "com.apple.trackpad.trackpadCornerClickBehavior" = null;
      };

      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
      WindowManager.StandardHideDesktopIcons = false;
      alf.stealthenabled = 1;

      dock = {
        autohide = true;
        show-recents = false;

        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;

        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        expose-animation-duration = 0.0;
        expose-group-apps = false;
        largesize = 64;
        launchanim = false;
        magnification = true;
        orientation = "bottom";
        show-process-indicators = true;
        tilesize = 48;
      };

      finder = {
        ShowPathbar = true;
        _FXShowPosixPathInTitle = true; # show full path in finder title
        AppleShowAllExtensions = true; # show all file extensions
        FXEnableExtensionChangeWarning = false; # disable warning when changing file extension
        QuitMenuItem = true; # enable quit menu item
      };

      loginwindow = {
        GuestEnabled = false;
      };

      screensaver = {
        askForPasswordDelay = 10;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;
  # FOR NEXT VERSION
  # security.pam.services.sudo_local.reattach = true;

  environment.systemPackages = with pkgs; [
    (symlinkJoin {
      name = "xdg-open-wrapper";
      paths = [
        (writeShellScriptBin "xdg-open" ''
          #!/bin/sh
          exec open "$@"
        '')
      ];
    })
  ];
}

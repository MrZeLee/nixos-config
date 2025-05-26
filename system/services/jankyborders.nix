{
  pkgs,
  lib,
  isDarwin,
  ...
}:
lib.mkIf isDarwin {
  launchd = {
    user = {
      agents = {
        borders = {
          serviceConfig = {
            Label = "com.example.borders"; # Updated label
            EnvironmentVariables = {
              LANG = "en_US.UTF-8";
              PATH = "${pkgs.jankyborders}/bin:${pkgs.jankyborders}/sbin:/usr/bin:/bin:/usr/sbin:/sbin";
            };
            KeepAlive = true;
            LimitLoadToSessionType = "Aqua";
            ProcessType = "Interactive";
            ProgramArguments = [
              "${pkgs.jankyborders}/bin/borders"
            ];
            RunAtLoad = true;
            StandardErrorPath = "/tmp/borders.err.log";
            StandardOutPath = "/tmp/borders/borders.out.log";
          };
        };
      };
    };
  };
}

{
  lib,
  pkgs,
  isDarwin,
  ...
}:
lib.mkIf isDarwin {
  launchd = {
    user = {
      agents = {
        tmux = {
          serviceConfig = {
            Label = "com.example.tmux";
            EnvironmentVariables = {
              LANG = "en_US.UTF-8";
              PATH = "${pkgs.tmux}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
            };
            KeepAlive = false;
            ProcessType = "Interactive";
            ProgramArguments = [
              "${pkgs.tmux}/bin/tmux"
              "new-session"
              "-d"
              "-s"
              "mydaemon"
            ];
            RunAtLoad = true;
            StandardErrorPath = "/tmp/tmux.err.log";
            StandardOutPath = "/tmp/tmux.out.log";
          };
        };
      };
    };
  };
}

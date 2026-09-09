{
  pkgs,
  lib,
  config,
  isLinux,
  ...
}:
let
  # oidc-prompt é uma GUI webkit: sem nixGL aborta com EGL_BAD_PARAMETER
  wrapGL = config.lib.nixGL.wrap;

  account = "my-client";
  sock = "%t/oidc-agent.sock";
  # A password vive no keyring que o pam_gnome_keyring desbloqueia no login,
  # por isso o agente carrega a conta sem prompt nenhum.
  pwCmd = "${pkgs.libsecret}/bin/secret-tool lookup service oidc-agent account ${account}";
in
{
  home.packages = with pkgs; [
    (wrapGL oidc-agent)
    libsecret
  ];

  # Sem --socket-path o agente cria $TMPDIR/oidc-XXXXXX/oidc-agent.<ppid>, o que
  # obrigaria a um `eval $(oidc-agent)` por shell; um socket fixo em
  # $XDG_RUNTIME_DIR torna OIDC_SOCK constante e exportável à sessão inteira.
  home.sessionVariables = lib.mkIf isLinux {
    OIDC_SOCK = "\${XDG_RUNTIME_DIR}/oidc-agent.sock";
  };

  # hm-session-vars.sh só é lido por shells; os serviços user (rclone e afins)
  # precisam da variável em environment.d para verem o mesmo socket.
  systemd.user.sessionVariables = lib.mkIf isLinux {
    OIDC_SOCK = "\${XDG_RUNTIME_DIR}/oidc-agent.sock";
  };

  systemd.user.services.oidc-agent = lib.mkIf isLinux {
    Unit = {
      Description = "oidc-agent";
      # Quando o refresh token expira o agente reautentica abrindo o browser,
      # logo precisa do DISPLAY/WAYLAND_DISPLAY que a sessão gráfica importa.
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    # --console: sem daemonizar, para o systemd seguir o próprio agente
    Service.ExecStart = "${pkgs.oidc-agent}/bin/oidc-agent --console --socket-path=${sock}";
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.oidc-add = lib.mkIf isLinux {
    Unit = {
      Description = "Carrega a conta ${account} no oidc-agent";
      Requires = [ "oidc-agent.service" ];
      After = [ "oidc-agent.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      Environment = [ "OIDC_SOCK=${sock}" ];
      # --pw-store: mantém a password em memória para as reautenticações
      ExecStart = "${pkgs.oidc-agent}/bin/oidc-add --pw-cmd='${pwCmd}' --pw-store ${account}";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}

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
in
{
  home.packages = with pkgs; [
    (wrapGL oidc-agent)
    # secret-tool: fonte de password para --pw-cmd, lida do keyring que o
    # pam_gnome_keyring desbloqueia no login
    libsecret
  ];

  # Sem --socket-path o agente cria $TMPDIR/oidc-XXXXXX/oidc-agent.<ppid>, o que
  # obrigaria a um `eval $(oidc-agent)` por shell; um socket fixo em
  # $XDG_RUNTIME_DIR torna OIDC_SOCK constante e exportável à sessão inteira.
  home.sessionVariables = lib.mkIf isLinux {
    OIDC_SOCK = "\${XDG_RUNTIME_DIR}/oidc-agent.sock";
  };

  systemd.user.services.oidc-agent = lib.mkIf isLinux {
    Unit.Description = "oidc-agent";
    # --console: sem daemonizar, para o systemd seguir o próprio agente
    Service.ExecStart = "${pkgs.oidc-agent}/bin/oidc-agent --console --socket-path=%t/oidc-agent.sock";
    Install.WantedBy = [ "default.target" ];
  };
}

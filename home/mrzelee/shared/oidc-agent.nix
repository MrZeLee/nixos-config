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
  sock = "$XDG_RUNTIME_DIR/oidc-agent.sock";
  # A password vive no keyring que o pam_gnome_keyring desbloqueia no login,
  # por isso a conta é carregada sem prompt nenhum.
  pwCmd = "${pkgs.libsecret}/bin/secret-tool lookup service oidc-agent account ${account}";
  systemctl = config.systemd.user.systemctlPath;
  loginctl = "${dirOf config.systemd.user.systemctlPath}/loginctl";
  graphicalTimeout = 30;

  # O systemd fixa o ambiente da unit no momento em que ela arranca, por isso
  # nem After= nem um ExecStartPre a esperar dariam display ao agente: ele
  # herdaria à mesma o ambiente de antes de o Hyprland correr
  # dbus-update-activation-environment. Esperamos aqui dentro e importamos as
  # variáveis do manager já no processo -- seguindo sem elas se a sessão
  # gráfica não aparecer, para o agente continuar utilizável em SSH/headless.
  waitForGraphical = ''
    # Esperar só faz sentido se o logind já registou uma sessão gráfica para
    # este utilizador; em SSH/headless a propriedade vem vazia e seguimos logo,
    # sem pagar o timeout.
    if [ -n "$(${loginctl} show-user "$UID" --property=Display --value 2>/dev/null)" ]; then
      for _ in {1..${toString graphicalTimeout}}; do
        ${systemctl} --user -q is-active graphical-session.target && break
        ${pkgs.coreutils}/bin/sleep 1
      done
    fi

    while IFS= read -r assignment; do
      case "$assignment" in
      DISPLAY=* | WAYLAND_DISPLAY=* | XDG_CURRENT_DESKTOP=* | XDG_SESSION_TYPE=* | HYPRLAND_INSTANCE_SIGNATURE=*)
        eval "export $assignment"
        ;;
      esac
    done < <(${systemctl} --user show-environment)
  '';

  startAgent = pkgs.writeShellScript "oidc-agent-start" ''
    ${waitForGraphical}
    exec ${pkgs.oidc-agent}/bin/oidc-agent --console --socket-path="${sock}"
  '';

  # Type=simple dá a unit por arrancada antes de o socket existir, e o agente
  # ainda espera pela sessão gráfica; esperamos pelo socket em vez do estado
  # da unit. Restart= não é permitido com Type=oneshot.
  addAccount = pkgs.writeShellScript "oidc-add-account" ''
    for _ in {1..${toString (graphicalTimeout + 30)}}; do
      [ -S "${sock}" ] && break
      ${pkgs.coreutils}/bin/sleep 1
    done
    export OIDC_SOCK="${sock}"
    # --pw-store: guarda a password em memória para as reautenticações seguintes
    exec ${pkgs.oidc-agent}/bin/oidc-add --pw-cmd='${pwCmd}' --pw-store ${account}
  '';
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
    Unit.Description = "oidc-agent";
    Service.ExecStart = "${startAgent}";
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.oidc-add = lib.mkIf isLinux {
    Unit = {
      Description = "Carrega a conta ${account} no oidc-agent";
      Requires = [ "oidc-agent.service" ];
      After = [ "oidc-agent.service" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${addAccount}";
    };
    Install.WantedBy = [ "default.target" ];
  };
}

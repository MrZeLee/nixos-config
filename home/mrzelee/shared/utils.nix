{
  pkgs,
  lib,
  config,
  isLinux,
  isDarwin,
  ...
}:
let
  wrapGL = config.lib.nixGL.wrap;
in
{
  home.packages =
    with pkgs;
    [
      # Security
      (wrapGL keepassxc)
      gnupg
      pass
      age

      # System
      pciutils

      # Network
      nmap
      netcat
      wget
      curl
      teleport_17

      # Misc
      (wrapGL obsidian)
      ghostscript
      (wrapGL pdfpc)
      # Qt/WebEngine para o fluxo OIDC: sem nixGL falha como o oidc-prompt.
      # Arranque manual; o .desktop que o cliente escreve aponta para o binario
      # cru e nao e lido por ninguem (o Hyprland nao le ~/.config/autostart).
      # QT_STYLE_OVERRIDE=adwaita-dark (qt.style, global) chega ao Qt Quick, que
      # tenta importar um modulo QML "adwaita-dark" que nao existe (adwaita-qt so
      # tem o plugin QStyle) e mata a janela principal. QT_QUICK_CONTROLS_STYLE
      # nao o anula: so o unset resolve, e so aqui -- mexer nele globalmente
      # rebenta o greeter do SDDM, que tambem e Qt Quick.
      (symlinkJoin {
        name = "owncloud-client-qml-style";
        paths = [ (wrapGL owncloud-client) ];
        nativeBuildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/owncloud --unset QT_STYLE_OVERRIDE
        '';
      })
    ]
    ++ lib.optionals isLinux [
      #System
      usbutils
      lshw

      #Misc
      (ledger.override {
        # gpgmeSupport dropped in 26.05: gpgme 2.0 split out gpgmepp, and
        # ledger's find_package(Gpgmepp 1.13.1) no longer resolves.
        usePython = true;
      })
      (wrapGL libreoffice)

      #Media
      bluetui

      #Network
      sshfs

      #Lightweight terminal
      (wrapGL enlightenment.terminology)
    ]
    ++ lib.optionals isDarwin [
    ];

}

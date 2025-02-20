{pkgs, ...}: {
  systemd.user.services.noisetorch = {
    description = "Noisetorch Noise Cancelling";
    after = ["wireplumber.service"];

    serviceConfig = {
      Type = "simple";
      RemainAfterExit = "yes";
      ExecStart = "${pkgs.noisetorch}/bin/noisetorch -i -s alsa_input.usb-Macronix_Razer_Barracuda_Pro_2.4_1234-00.mono-fallback -t 95";
      ExecStop = "${pkgs.noisetorch}/bin/noisetorch -u";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 10s";
    };

    wantedBy = [
      "default.target"
    ];
  };
}

# omdrop-awdl: firmware-native AWDL (AirDrop's link layer) on the BCM4387.
# NixOS port of upstream's PKGBUILD: the brcmfmac patches go into the Asahi
# kernel instead of DKMS, and the helpers live in the store instead of
# /usr/lib/omdrop. Rolling back a generation restores the stock driver.
{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  src = inputs.omdrop-awdl;

  python = pkgs.python3.withPackages (
    ps: with ps; [
      libarchive-c
      pillow
      zeroconf
      ifaddr
      # BLE wake advert for naming Contacts Only peers
      dbus-python
      pygobject3
    ]
  );

  # pkexec clears PATH, so the helpers carry everything they call
  runtimePath = lib.makeBinPath (
    [ python ]
    ++ (with pkgs; [
      coreutils
      gnugrep
      gnused
      gawk
      findutils
      util-linux
      procps
      iproute2
      iputils
      iw
      kmod
      networkmanager
      systemd
      keyutils
      zstd
      xz
      gzip
    ])
  );

  omdrop-awdl = pkgs.stdenvNoCC.mkDerivation {
    pname = "omdrop-awdl";
    version = "0-unstable-2026-10-10";
    inherit src;

    nativeBuildInputs = [ pkgs.makeWrapper ];
    buildInputs = [
      python
      pkgs.bash
    ];

    installPhase = ''
      runHook preInstall

      lib=$out/lib/omdrop
      install -Dm755 -t $lib userspace/omdrop-discoverable userspace/awdl-up \
        userspace/send-to-peer userspace/awdl-resolve userspace/*.py
      install -Dm644 packaging/org.omarchy.omdrop.policy \
        $out/share/polkit-1/actions/org.omarchy.omdrop.policy
      install -Dm644 packaging/99-awdl-unmanaged.conf \
        $out/lib/NetworkManager/conf.d/99-awdl-unmanaged.conf

      # The polkit grant is bound to the helper's exact path; the store is
      # root-owned, which is the property /usr/lib/omdrop gave upstream.
      substituteInPlace $lib/* $out/share/polkit-1/actions/*.policy \
        --replace-quiet /usr/lib/omdrop $lib
      # NixOS owns /etc/NetworkManager (networking.networkmanager.unmanaged
      # below); pointing at the vendor copy stops awdl-up writing its own.
      substituteInPlace $lib/awdl-up --replace-fail \
        /usr/lib/NetworkManager/conf.d $out/lib/NetworkManager/conf.d

      for f in omdrop-discoverable awdl-up send-to-peer awdl-resolve; do
        wrapProgram $lib/$f --prefix PATH : ${runtimePath}
      done

      runHook postInstall
    '';
  };

  # omarchy-notification-send's flags on top of notify-send; --exec runs on click
  notify-shim = pkgs.writeShellScriptBin "omarchy-notification-send" ''
    t=5000 img= args=() run=()
    while (( $# )); do
      case $1 in
        -t) t=$2; shift 2 ;;
        --image) img=$2; shift 2 ;;
        --exec) shift; run=("$@"); break ;;
        *) args+=("$1"); shift ;;
      esac
    done
    (( ''${#run[@]} )) || exec notify-send -t "$t" ''${img:+-i "$img"} "''${args[@]}"
    ( [[ $(notify-send -t "$t" ''${img:+-i "$img"} -A default=Open "''${args[@]}") == default ]] \
        && "''${run[@]}" ) >/dev/null 2>&1 &
  '';
  browser-shim = pkgs.writeShellScriptBin "omarchy-launch-browser" ''exec xdg-open "$@"'';

  # The plugin's CLI and receiver, minus its QML panel (waybar replaces it)
  omdrop = pkgs.stdenvNoCC.mkDerivation {
    pname = "omdrop";
    version = "0.15.1";
    src = inputs.omdrop-plugin;

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      runHook preInstall

      # plugin_dir() finds its files by the manifest beside bin/
      dir=$out/share/omdrop-plugin
      mkdir -p $dir $out/bin
      cp -r bin share manifest.json README.md $dir/
      ln -s $dir/bin/omdrop $out/bin/omdrop

      substituteInPlace $dir/share/airdrop-receiver.service \
        --replace-fail /usr/bin/python3 ${python}/bin/python3
      substituteInPlace $dir/bin/identity.py \
        --replace-fail "'libkeyutils.so.1'" "'${pkgs.keyutils.lib}/lib/libkeyutils.so.1'"
      substituteInPlace $dir/bin/omdrop \
        --replace-fail /usr/lib/libkeyutils.so.1 ${pkgs.keyutils.lib}/lib/libkeyutils.so.1 \
        --replace-fail '"$current" == */plugins/*/bin/omdrop ]]' \
                       '"$current" == */plugins/*/bin/omdrop || "$current" == /nix/store/* ]]'

      wrapProgram $dir/bin/omdrop \
        --set OMDROP_DISCOVERABLE ${omdrop-awdl}/lib/omdrop/omdrop-discoverable \
        --set OMDROP_SENDER ${omdrop-awdl}/lib/omdrop/send-to-peer \
        --prefix PATH : ${
          lib.makeBinPath [
            python
            notify-shim
            browser-shim
            pkgs.libnotify
            pkgs.xdg-utils
            pkgs.wl-clipboard
          ]
        }:${runtimePath}

      runHook postInstall
    '';
  };

  # waybar: `status` prints the module JSON, `send` picks a peer and files
  omdrop-waybar = pkgs.writeShellApplication {
    name = "omdrop-waybar";
    runtimeInputs = [
      omdrop
      pkgs.jq
      pkgs.fuzzel
      pkgs.libnotify
    ];
    text = ''
      case ''${1:-status} in
        status)
          omdrop status --json | jq -c '
            if .receiving then
              { text: "󰀂", class: "on",
                tooltip: ("AirDrop: visible as \(.name) to \(.visibility)"
                  + (if .remaining then " (\(.remaining / 60 | floor)m left)" else "" end)
                  + "\nLeft: off · Right: send") }
            else
              { text: "󰀂", class: "off", tooltip: "AirDrop: off\nLeft: on 10m · Right: send" }
            end' ;;
        send)
          # the receive window is what hears peers
          if ! omdrop status --json | jq -e .receiving >/dev/null; then
            err=$(omdrop on 10m 2>&1 >/dev/null) || { notify-send -u critical AirDrop "$err"; exit 1; }
          fi
          notify-send -t 15000 AirDrop "Looking for nearby devices…"
          peers=$(omdrop peers --json -n 2>/dev/null) || peers='[]'
          if [[ $(jq length <<<"$peers") == 0 ]]; then
            notify-send AirDrop "No devices found. Open the AirDrop sheet on the other device and try again."
            exit 0
          fi
          mac=$(jq -r '.[] | "\(.name // "unnamed")\t\(.mac)\t\(.rssi // "?") dBm"' <<<"$peers" \
            | fuzzel --dmenu --prompt "Send to: " | cut -f2) || exit 0
          [[ -n $mac ]] || exit 0
          if out=$(omdrop send --pick --to "$mac" 2>&1); then
            notify-send AirDrop "$(tail -n1 <<<"$out")"
          else
            # 1 = chooser cancelled
            [[ $? -eq 1 && -z $out ]] || notify-send -u critical AirDrop "$(tail -n1 <<<"$out")"
          fi ;;
      esac
    '';
  };

  patches = lib.filter (lib.hasSuffix ".patch") (lib.filesystem.listFilesRecursive "${src}/patches");
in
{
  boot.kernelPatches =
    map (p: {
      name = lib.removeSuffix ".patch" (baseNameOf p);
      patch = p;
    }) patches
    ++ [
      {
        # upstream's DKMS build sets it; 0010's firmware snapshot needs it
        name = "omdrop-awdl-brcmdbg";
        patch = null;
        structuredExtraConfig.BRCMDBG = lib.kernel.yes;
      }
    ];

  boot.extraModprobeConfig = ''
    options brcmfmac debug=0x1000
  '';

  # a managed awdl0 gets a random MAC and no link-local; both break AirDrop
  networking.networkmanager.unmanaged = [ "interface-name:awdl0" ];

  # provides the polkit action, so the desktop session can pkexec the helper
  environment.systemPackages = [
    omdrop-awdl
    omdrop
    omdrop-waybar
  ];

  # the receiver; upstream's ufw rule, scoped to awdl0 (link-local only)
  networking.firewall.interfaces.awdl0.allowedTCPPorts = [ 8771 ];

  # creates awdl0 at boot without enabling AWDL; omdrop-discoverable opens windows
  systemd.services.awdl0 = {
    description = "Create and configure awdl0 (firmware-native AWDL on BCM4387)";
    documentation = [ "https://github.com/brentkearney/omdrop-awdl" ];
    after = [ "NetworkManager.service" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionPathExists = "/sys/module/brcmfmac";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${omdrop-awdl}/lib/omdrop/awdl-up";
      TimeoutStartSec = 180;
    };
  };
}

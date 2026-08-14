{ lib, pkgs, ... }:
let
  kodi = pkgs.kodi-gbm.withPackages (kp: [
    kp.jellyfin
    kp.joystick # peripheral.joystick — required for gamepad input
    kp.pvr-iptvsimple # live TV from an M3U playlist (EPG via XMLTV)
    (kp.buildKodiAddon {
      pname = "moonlight-launcher";
      namespace = "script.moonlight-launcher";
      version = "1.0.0";
      src = ./kodi-moonlight-addon;
    })
    (kp.buildKodiAddon {
      pname = "tailscale-toggle";
      namespace = "script.tailscale-toggle";
      version = "1.0.0";
      src = ./kodi-tailscale-addon;
    })
    (kp.buildKodiAddon {
      pname = "pia-vpn";
      namespace = "script.pia-vpn";
      version = "1.0.0";
      src = ./kodi-pia-addon;
    })
  ]);

  # Session loop: Kodi owns the screen; the Moonlight addon drops a flag
  # file and quits Kodi, we run moonlight-qt on KMS, then Kodi comes back.
  htpc-session = pkgs.writeShellScriptBin "htpc-session" ''
    exec > "$XDG_RUNTIME_DIR/htpc-session.log" 2>&1
    flag="$XDG_RUNTIME_DIR/launch-moonlight"
    while true; do
      rm -f "$flag"
      ${kodi}/bin/kodi
      if [ -e "$flag" ]; then
        QT_QPA_PLATFORM=eglfs ${lib.getExe pkgs.moonlight-qt}
      fi
    done
  '';
in
{
  imports = [
    ./hardware-configuration.nix
    ../../../system/services/tailscale.nix
  ];

  # The Kodi addon drives the tailscale CLI. Operator mode can't cover
  # login: logout wipes OperatorUser from the profile, and getting it
  # back needs root. So: sudo for exactly this one binary.
  security.sudo.extraRules = [
    {
      users = [ "htpc" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/tailscale";
          options = [ "NOPASSWD" ];
        }
        # The PIA addon toggles the VPN service and switches region —
        # exactly these commands, nothing broader.
        {
          command = "/run/current-system/sw/bin/systemctl start openvpn-pia.service";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl stop openvpn-pia.service";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl restart openvpn-pia.service";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/tee /var/lib/pia/remote.conf";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/tee /etc/pia/auth.txt";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nft list table inet pia-killswitch";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nft delete table inet pia-killswitch";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nft -f /etc/pia-killswitch.nft";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # qrencode: tailscale addon's login QR. nftables: PIA kill-switch toggle.
  environment.systemPackages = [
    pkgs.qrencode
    pkgs.nftables
  ];

  # Kodi remote control (Kore app / web UI) + EventServer.
  networking.firewall.allowedTCPPorts = [ 8080 ];
  networking.firewall.allowedUDPPorts = [ 9777 ];

  # PIA VPN for the whole box, on from boot; the Kodi addon manages it
  # (connect, region, kill switch, credentials via its Login option).
  services.openvpn.servers.pia = {
    autoStart = true;
    # Apply PIA's pushed DNS while the tunnel is up (removed on stop).
    updateResolvConf = true;
    config = ''
      client
      dev tun
      proto udp
      config /var/lib/pia/remote.conf
      resolv-retry infinite
      nobind
      persist-key
      persist-tun
      data-ciphers AES-256-GCM:AES-256-CBC
      cipher AES-256-CBC
      auth sha256
      remote-cert-tls server
      auth-user-pass /etc/pia/auth.txt
      reneg-sec 0
      verb 1
      ca ${
        pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/pia-foss/manual-connections/master/ca.rsa.4096.crt";
          sha256 = "1av6dilvm696h7pb5xn91ibw0mrziqsnwk51y8a7da9y8g8v3s9j";
        }
      }
    '';
  };

  # Kill switch, scoped to the htpc user: Kodi (IPTV included) can only
  # reach the internet through the tunnel — VPN off means no streams,
  # IPv6 too, which would otherwise bypass the v4-only tunnel. LAN keeps
  # working (Jellyfin, Kore, router DNS), and everything not running as
  # htpc (tailscale, deploys, NTP) is untouched. Armed at boot and on
  # every VPN start; the Kodi addon can lift it temporarily.
  # Stable path so the Kodi addon can re-arm it too (sudo rule above).
  environment.etc."pia-killswitch.nft".source = pkgs.writeText "pia-killswitch.nft" ''
    table inet pia-killswitch {}
    delete table inet pia-killswitch
    table inet pia-killswitch {
      set whitelist {
        type ipv4_addr
      }
      chain dns-whitelist {
        type nat hook output priority -100; policy accept;
        oifname != "tun0" meta skuid "htpc" udp dport 53 redirect to :5453
        oifname != "tun0" meta skuid "htpc" tcp dport 53 redirect to :5453
      }
      chain output {
        type filter hook output priority filter; policy accept;
        meta skuid != "htpc" accept
        oifname { "lo", "tun0" } accept
        ct state { established, related } accept
        ip daddr @whitelist accept comment "populated by dnsmasq from whitelisted lookups"
        ip daddr 127.0.0.0/8 accept comment "redirected DNS: at filter time oif still shows the original iface, not lo"
        ip6 daddr ::1 accept
        ip daddr { 10.0.0.0/8, 100.64.0.0/10, 172.16.0.0/12, 192.168.0.0/16, 224.0.0.0/4 } accept comment "LAN, tailnet, multicast"
        ip6 daddr { fe80::/10, ff02::/16 } accept comment "NDP + mDNS"
        drop
      }
    }
  '';

  # DNS whitelist for Kodi while the VPN is down: the nat chain above
  # redirects htpc's DNS (unless it rides the tunnel) to this resolver,
  # which only answers the domains below — NXDOMAIN for everything else,
  # so no lookup metadata leaks to the ISP. Resolved IPs land in the
  # kill-switch set, so exactly these hosts stay reachable (Jellyfin
  # despite its dynamic IP; PIA's serverlist so the addon can pick a
  # region before first login; ipinfo for the Status screen).
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false; # only Kodi's redirected queries, not the system's
    settings = {
      port = 5453;
      listen-address = "127.0.0.1";
      bind-interfaces = true;
      no-resolv = true;
      server = [
        "/mourahouse.com/1.1.1.1"
        "/piaservers.net/1.1.1.1"
        "/privateinternetaccess.com/1.1.1.1"
        "/ip-api.com/1.1.1.1"
      ];
      nftset = [
        "/jellyfin.mourahouse.com/piaservers.net/privateinternetaccess.com/ip-api.com/4#inet#pia-killswitch#whitelist"
      ];
      address = "/#/";
    };
  };

  systemd.services.pia-killswitch = {
    description = "Kodi-only-via-VPN kill switch";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.nftables}/bin/nft -f /etc/pia-killswitch.nft";
      ExecStop = "${pkgs.nftables}/bin/nft delete table inet pia-killswitch";
    };
  };

  # Re-arm on every connect, in case the addon lifted it.
  systemd.services.openvpn-pia.serviceConfig.ExecStartPre =
    "${pkgs.nftables}/bin/nft -f /etc/pia-killswitch.nft";

  # Radio playlists from radio-browser.info (popularity-sorted), rewritten
  # with radio="true" so Kodi files the stations under Radio, not TV.
  # Fetched by root at boot + weekly, so the list refreshes regardless of
  # the kill switch; playback itself is still Kodi traffic (VPN-gated).
  systemd.services.radio-playlists = {
    description = "Fetch radio playlists for IPTV Simple";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    startAt = "weekly";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /var/lib/iptv
      for cc in pt fr; do
        ${pkgs.curl}/bin/curl -sf --max-time 60 \
          "https://de1.api.radio-browser.info/m3u/stations/bycountrycodeexact/$cc?hidebroken=true&order=clickcount&reverse=true" \
          | ${pkgs.gnused}/bin/sed 's/^#EXTINF:1,/#EXTINF:-1 radio="true",/' \
          > /var/lib/iptv/radio-$cc.m3u.tmp \
          && mv /var/lib/iptv/radio-$cc.m3u.tmp /var/lib/iptv/radio-$cc.m3u
      done
    '';
  };

  # Answer for htpc.local on the LAN (mDNS).
  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  # Seed IPTV Simple with iptv-org's public playlists (one addon instance
  # per country). `C` only copies if the file doesn't exist, so Kodi owns
  # them afterwards.
  systemd.tmpfiles.rules =
    let
      iptvInstance =
        name: country:
        pkgs.writeText "iptvsimple-${country}.xml" ''
          <?xml version="1.0" encoding="utf-8"?>
          <settings version="2">
            <setting id="kodi_addon_instance_name">${name}</setting>
            <setting id="kodi_addon_instance_enabled">true</setting>
            <setting id="m3uPathType">1</setting>
            <setting id="m3uUrl">https://iptv-org.github.io/iptv/countries/${country}.m3u</setting>
          </settings>
        '';
      radioInstance =
        name: cc:
        pkgs.writeText "iptvsimple-radio-${cc}.xml" ''
          <?xml version="1.0" encoding="utf-8"?>
          <settings version="2">
            <setting id="kodi_addon_instance_name">${name}</setting>
            <setting id="kodi_addon_instance_enabled">true</setting>
            <setting id="m3uPathType">0</setting>
            <setting id="m3uPath">/var/lib/iptv/radio-${cc}.m3u</setting>
          </settings>
        '';
    in
    [
      "d /home/htpc/.kodi 0755 htpc users -"
      "d /home/htpc/.kodi/userdata 0755 htpc users -"
      "d /home/htpc/.kodi/userdata/addon_data 0755 htpc users -"
      "d /home/htpc/.kodi/userdata/addon_data/pvr.iptvsimple 0755 htpc users -"
      "C /home/htpc/.kodi/userdata/addon_data/pvr.iptvsimple/instance-settings-1.xml 0644 htpc users - ${iptvInstance "Portugal" "pt"}"
      "C /home/htpc/.kodi/userdata/addon_data/pvr.iptvsimple/instance-settings-2.xml 0644 htpc users - ${iptvInstance "France" "fr"}"
      "C /home/htpc/.kodi/userdata/addon_data/pvr.iptvsimple/instance-settings-3.xml 0644 htpc users - ${radioInstance "Rádio Portugal" "pt"}"
      "C /home/htpc/.kodi/userdata/addon_data/pvr.iptvsimple/instance-settings-4.xml 0644 htpc users - ${radioInstance "Radio France" "fr"}"
      # PIA credentials, written by the addon's Login option. Pre-created
      # root-only so the sudo tee write never leaves them world-readable.
      "d /etc/pia 0755 root root -"
      "f /etc/pia/auth.txt 0600 root root -"
      # PIA region, rewritten by the Kodi addon; seeded once.
      "d /var/lib/pia 0755 root root -"
      "C /var/lib/pia/remote.conf 0644 root root - ${pkgs.writeText "pia-remote.conf" ''
        remote portugal.pvt.site 1197
      ''}"
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1; # show the generation menu for just a second

  # Quiet boot: no kernel/systemd text on the TV, and no blinking cursor
  # on the console that flashes between Kodi and Moonlight.
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "udev.log_level=3"
    "vt.global_cursor_default=0"
  ];

  networking.hostName = "htpc";

  hardware.enableRedistributableFirmware = true;

  # Mesa: RADV for Vulkan, radeonsi VAAPI for Kodi/Moonlight. No amdvlk.
  hardware.graphics.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  users.mutableUsers = false;

  users.users.htpc = {
    isNormalUser = true;
    extraGroups = [
      "video"
      "render"
      "input"
      "dialout" # Pulse-Eight USB-CEC adapter (ttyACM)
    ];
  };

  users.users.mrzelee = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxGPJr0yZ9d+SOYqmEBP2GPejrfbAc45Ijsvk3PWYEP mrzelee404@gmail.com"
    ];
  };

  # No passwords exist (mutableUsers = false, key-only SSH), so wheel
  # must sudo without one — also what remote nixos-rebuild --sudo needs.
  security.sudo.wheelNeedsPassword = false;

  # Autologin straight into the Kodi/Moonlight session loop on tty1.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${htpc-session}/bin/htpc-session";
      user = "htpc";
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # First install of this box; do not bump on upgrades.
  system.stateVersion = "26.05";
}

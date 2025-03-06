{
  pkgs,
  lib,
  ...
}: let
  dbusSessionConf =
    builtins.replaceStrings
    ["<include ignore_missing=\"yes\">/etc/dbus-1/session.conf</include>"]
    ["<!-- <include ignore_missing=\"yes\">/etc/dbus-1/session.conf</include> -->"]
    (builtins.replaceStrings
      ["<auth>EXTERNAL</auth>"]
      ["<auth>DBUS_COOKIE_SHA1</auth>"]
      (builtins.readFile "${pkgs.dbus}/share/dbus-1/session.conf"));
in {
  environment = {
    systemPackages = with pkgs; [
      dbus
      glib
    ];
    etc = lib.optionalAttrs pkgs.stdenv.isDarwin {
      "dbus-1/session.conf".text = dbusSessionConf;
    };
  };

  launchd.agents."org.freedesktop.dbus-session" = {
    command = "${pkgs.dbus}/bin/dbus-daemon --nofork --session --address=unix:path=$DBUS_LAUNCHD_SESSION_BUS_SOCKET";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = true;
      Sockets."unix_domain_listener".SecureSocketWithKey = "DBUS_LAUNCHD_SESSION_BUS_SOCKET";
      Label = "org.freedesktop.dbus-session"; # Updated label
      EnvironmentVariables = {
        LANG = "en_US.UTF-8";
        PATH = "${pkgs.dbus}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
      StandardOutPath = "/tmp/dbus.out.log";
      StandardErrorPath = "/tmp/dbus.err.log";
    };
  };
}

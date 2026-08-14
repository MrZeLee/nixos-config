import base64
import json
import os
import subprocess
import time
import urllib.error
import urllib.request

import xbmcgui

# htpc has passwordless sudo for exactly these commands (see default.nix).
SUDO = "/run/wrappers/bin/sudo"
SYSTEMCTL = "/run/current-system/sw/bin/systemctl"
TEE = "/run/current-system/sw/bin/tee"
NFT = "/run/current-system/sw/bin/nft"
UNIT = "openvpn-pia.service"
REMOTE_CONF = "/var/lib/pia/remote.conf"
AUTH_FILE = "/etc/pia/auth.txt"
KILLSWITCH_RULES = "/etc/pia-killswitch.nft"
SERVERLIST = "https://serverlist.piaservers.net/vpninfo/servers/v6"
IPCHECK = "http://ip-api.com/json"  # free tier is http-only; it's public info
TOKEN_API = "https://www.privateinternetaccess.com/gtoken/generateToken"
TUN = "/sys/class/net/tun0"


def creds_valid(user, pw):
    # True/False, or None when the check itself is unreachable.
    req = urllib.request.Request(TOKEN_API)
    cred = base64.b64encode(("%s:%s" % (user, pw)).encode()).decode()
    req.add_header("Authorization", "Basic " + cred)
    try:
        urllib.request.urlopen(req, timeout=15).close()
        return True
    except urllib.error.HTTPError:
        return False
    except OSError:
        return None
REGIONS_CACHE = "/home/htpc/.kodi/userdata/addon_data/script.pia-vpn/regions.json"


def fetch_regions():
    # The kill switch blocks this while the VPN is down — fall back to
    # the list cached from the last successful fetch.
    try:
        with urllib.request.urlopen(SERVERLIST, timeout=15) as resp:
            # First line of the body is JSON, the rest a signature.
            regions = json.loads(resp.read().decode().split("\n")[0])["regions"]
        os.makedirs(os.path.dirname(REGIONS_CACHE), exist_ok=True)
        with open(REGIONS_CACHE, "w") as f:
            json.dump(regions, f)
    except OSError:
        try:
            with open(REGIONS_CACHE) as f:
                regions = json.load(f)
        except OSError:
            raise RuntimeError("region list needs internet — connect the VPN first")
    return regions


def run(*cmd, stdin=None, timeout=90):
    r = subprocess.run(
        cmd, input=stdin, capture_output=True, text=True, timeout=timeout
    )
    if r.returncode != 0:
        raise RuntimeError(r.stderr.strip() or "command failed")
    return r.stdout


def quiet(*cmd):
    return subprocess.run(cmd, capture_output=True).returncode == 0


try:
    dialog = xbmcgui.Dialog()
    active = quiet(SYSTEMCTL, "is-active", "--quiet", UNIT)
    # Service active but no tun0 = still handshaking, or auth failing.
    up = os.path.isdir(TUN)
    state = "connected" if up else ("connecting... (check login)" if active else "disconnected")
    armed = quiet(SUDO, "-n", NFT, "list", "table", "inet", "pia-killswitch")
    try:
        with open(REMOTE_CONF) as f:
            region = f.read().split()[1].split(".")[0]
    except OSError:
        region = "?"

    choice = dialog.select(
        "PIA VPN: %s (%s)" % (state, region),
        [
            "Disconnect" if active else "Connect",
            "Region...",
            "Status...",
            "Kill switch: %s" % ("armed" if armed else "off"),
            "Login...",
        ],
    )
    if choice == 0:
        if active:
            run(SUDO, "-n", SYSTEMCTL, "stop", UNIT)
            dialog.notification("PIA VPN", "Disconnected")
        else:
            run(SUDO, "-n", SYSTEMCTL, "start", UNIT)
            for _ in range(20):
                if os.path.isdir(TUN):
                    break
                time.sleep(1)
            if os.path.isdir(TUN):
                dialog.notification("PIA VPN", "Connected")
            else:
                dialog.notification(
                    "PIA VPN",
                    "Not connected — check Login/Status",
                    xbmcgui.NOTIFICATION_WARNING,
                )
    elif choice == 1:
        regions = fetch_regions()
        regions.sort(key=lambda r: r["name"])
        sel = dialog.select("PIA region", [r["name"] for r in regions])
        if sel >= 0:
            run(
                SUDO, "-n", TEE, REMOTE_CONF,
                stdin="remote %s 1197\n" % regions[sel]["dns"],
            )
            if active:
                run(SUDO, "-n", SYSTEMCTL, "restart", UNIT)
            dialog.notification("PIA VPN", "Region: %s" % regions[sel]["name"])
    elif choice == 2:
        try:
            with urllib.request.urlopen(IPCHECK, timeout=10) as resp:
                info = json.loads(resp.read().decode())
        except OSError:
            info = {}
        dialog.ok(
            "PIA VPN status",
            "[CR]".join(
                [
                    "VPN: %s — region %s" % (state, region),
                    "Public IP: %s (%s)" % (
                        info.get("query", "unreachable — kill switch?"),
                        info.get("isp", "?"),
                    ),
                    "Location: %s, %s" % (
                        info.get("city", "?"), info.get("country", "?")
                    ),
                    "Kill switch: %s" % ("armed" if armed else "off"),
                ]
            ),
        )
    elif choice == 3:
        if armed:
            run(SUDO, "-n", NFT, "delete", "table", "inet", "pia-killswitch")
            dialog.notification("PIA VPN", "Kill switch off until next connect")
        else:
            run(SUDO, "-n", NFT, "-f", KILLSWITCH_RULES)
            dialog.notification("PIA VPN", "Kill switch armed")
    elif choice == 4:
        user = dialog.input("PIA username (p1234567)")
        if user:
            pw = dialog.input("PIA password", option=xbmcgui.ALPHANUM_HIDE_INPUT)
            if pw:
                valid = creds_valid(user, pw)
                if valid is False:
                    dialog.notification(
                        "PIA VPN",
                        "Wrong username or password",
                        xbmcgui.NOTIFICATION_ERROR,
                    )
                else:
                    run(SUDO, "-n", TEE, AUTH_FILE, stdin="%s\n%s\n" % (user, pw))
                    if active:
                        run(SUDO, "-n", SYSTEMCTL, "restart", UNIT)
                    dialog.notification(
                        "PIA VPN",
                        "Login OK" if valid else "Saved (offline — not verified)",
                    )
except Exception as e:
    xbmcgui.Dialog().notification("PIA VPN", str(e), xbmcgui.NOTIFICATION_ERROR)
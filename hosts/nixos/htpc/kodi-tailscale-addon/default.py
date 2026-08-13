import json
import subprocess
import threading

import xbmcgui

# htpc has passwordless sudo for exactly this binary (see default.nix).
SUDO = "/run/wrappers/bin/sudo"
TS = "/run/current-system/sw/bin/tailscale"
QRENCODE = "/run/current-system/sw/bin/qrencode"
QR_PNG = "/tmp/tailscale-login-qr.png"


def ts(*args, timeout=30):
    r = subprocess.run(
        [SUDO, "-n", TS, *args], capture_output=True, text=True, timeout=timeout
    )
    if r.returncode != 0:
        raise RuntimeError(r.stderr.strip() or r.stdout.strip())
    return r.stdout


class QrDialog(xbmcgui.WindowDialog):
    def __init__(self, url):
        self.addControl(xbmcgui.ControlImage(440, 120, 400, 400, QR_PNG))
        self.addControl(
            xbmcgui.ControlLabel(0, 540, 1280, 30, url, alignment=2)
        )
        self.addControl(
            xbmcgui.ControlLabel(
                0, 580, 1280, 30, "Scan to authenticate — Back to cancel", alignment=2
            )
        )

    def onAction(self, action):
        if action.getId() in (9, 10, 92):  # back / previous menu
            self.close()


DEFAULT_LOGIN_SERVER = "https://controlplane.tailscale.com"


def login(dialog):
    server = dialog.input("Login server", DEFAULT_LOGIN_SERVER)
    if not server:
        return
    cmd = [SUDO, "-n", TS, "login"]
    if server != DEFAULT_LOGIN_SERVER:
        cmd.append("--login-server=" + server)
    proc = subprocess.Popen(
        cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
    )
    assert proc.stdout is not None
    url = None
    for line in proc.stdout:
        line = line.strip()
        if line.startswith("https://"):
            url = line
            break
    if url is None:
        proc.wait(timeout=30)
        raise RuntimeError("no login URL from tailscale login")

    subprocess.run([QRENCODE, "-s", "8", "-o", QR_PNG, url], check=True, timeout=15)
    win = QrDialog(url)
    threading.Thread(target=lambda: (proc.wait(), win.close()), daemon=True).start()
    win.doModal()
    if proc.poll() is None:  # user backed out
        try:
            proc.kill()
        except PermissionError:
            pass  # sudo child is root-owned; it exits on the next login attempt
        dialog.notification("Tailscale", "Login cancelled")
    else:
        dialog.notification("Tailscale", "Logged in")


try:
    dialog = xbmcgui.Dialog()
    status = json.loads(ts("status", "--json"))
    state = status["BackendState"]  # Running / Stopped / NeedsLogin
    prefs = json.loads(ts("debug", "prefs"))
    dns_on = prefs.get("CorpDNS", True)
    routes_on = prefs.get("RouteAll", False)

    if state == "NeedsLogin":
        first = "Log in (QR code)..."
    elif state == "Running":
        first = "Disconnect"
    else:
        first = "Connect"

    choice = dialog.select(
        "Tailscale: %s" % state.lower(),
        [
            first,
            "Exit node...",
            "Accept DNS: %s" % ("on" if dns_on else "off"),
            "Accept routes: %s" % ("on" if routes_on else "off"),
        ],
    )
    if choice == 0:
        if state == "NeedsLogin":
            login(dialog)
        else:
            # Bare `up` (no flags) just reconnects with existing prefs; any
            # flag would trigger tailscale's re-specify-everything check.
            ts("down" if state == "Running" else "up")
            dialog.notification(
                "Tailscale", "Disconnected" if state == "Running" else "Connected"
            )
    elif choice == 1:
        peers = [
            p["DNSName"].rstrip(".")
            for p in (status.get("Peer") or {}).values()
            if p.get("ExitNodeOption")
        ]
        sel = dialog.select("Exit node", ["(none)"] + peers)
        if sel == 0:
            ts("set", "--exit-node=")
            dialog.notification("Tailscale", "Exit node cleared")
        elif sel > 0:
            ts("set", "--exit-node=" + peers[sel - 1])
            dialog.notification("Tailscale", "Exit node: " + peers[sel - 1])
    elif choice == 2:
        ts("set", "--accept-dns=%s" % str(not dns_on).lower())
        dialog.notification("Tailscale", "Accept DNS: %s" % ("off" if dns_on else "on"))
    elif choice == 3:
        ts("set", "--accept-routes=%s" % str(not routes_on).lower())
        dialog.notification(
            "Tailscale", "Accept routes: %s" % ("off" if routes_on else "on")
        )
except Exception as e:
    xbmcgui.Dialog().notification("Tailscale", str(e), xbmcgui.NOTIFICATION_ERROR)
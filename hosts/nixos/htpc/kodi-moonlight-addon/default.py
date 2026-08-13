import os

import xbmc

# The session wrapper watches for this flag and launches moonlight-qt
# after Kodi exits.
flag = os.path.join(os.environ["XDG_RUNTIME_DIR"], "launch-moonlight")
open(flag, "w").close()
xbmc.executebuiltin("Quit")

{ nixpkgs }:
final: prev: {
  waypaper = prev.callPackage ./waypaper { };
  swww = prev.callPackage ./swww { };
  fleet-cli = prev.callPackage ./fleet-cli { };
  # wezterm = prev.callPackage ./wezterm {};
  # koji = prev.callPackage ./koji {};
  mmex = prev.callPackage ./mmex { };
  optcg-sim = prev.callPackage ./optcg-sim { };
  # mode_split hardcodes `wasd` as aliases for `hjkl` (home_row_keys can't
  # shadow them -- only the click indices short-circuit), and offers no way
  # back to the initial area short of repeated backspaces. The patch drops the
  # wasd aliases and binds `;` to reset. It fails the build if upstream moves.
  wl-kbptr = prev.wl-kbptr.overrideAttrs (o: {
    patches = (o.patches or [ ]) ++ [ ./wl-kbptr/vim-keys.patch ];
  });
  # Hyprland drops monitors hotplugged on a KMS device that has no render node
  # (Asahi's apple KMS, evdi/DisplayLink). See the patch header.
  aquamarine = prev.aquamarine.overrideAttrs (o: {
    patches = (o.patches or [ ]) ++ [ ./aquamarine/hotplug-no-render-node.patch ];
  });
  # codex = prev.callPackage ./codex {};
  # gnucash = prev.callPackage ./gnucash {};
}

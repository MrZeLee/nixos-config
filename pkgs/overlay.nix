{nixpkgs}: final: prev: {
  waypaper = prev.callPackage ./waypaper {};
  swww = prev.callPackage ./swww {};
  fleet-cli = prev.callPackage ./fleet-cli {};
  # wezterm = prev.callPackage ./wezterm {};
  # koji = prev.callPackage ./koji {};
  mmex = prev.callPackage ./mmex {};
  tree-sitter-0_26 = prev.callPackage ./tree-sitter-0_26 {};
  # codex = prev.callPackage ./codex {};
  # gnucash = prev.callPackage ./gnucash {};
}

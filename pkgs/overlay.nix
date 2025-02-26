{nixpkgs}: final: prev: {
  waypaper = prev.callPackage ./waypaper {};
  swww = prev.callPackage ./swww {};
  fleet-cli = prev.callPackage ./fleet-cli {};
  wezterm = prev.callPackage ./wezterm {};
  koji = prev.callPackage ./koji {};
  mmex = prev.callPackage ./mmex {};
  gnucash = prev.callPackage ./gnucash {};
}

{lib, ...}:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  networking.nameservers = lib.mkBefore ["100.100.100.100" "8.8.8.8" "1.1.1.1"];
  networking.search = ["tailc09c73.ts.net"];
}

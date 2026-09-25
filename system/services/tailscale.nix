{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # No static nameservers here: tailscaled installs 100.100.100.100 and the
  # tailnet search domain itself while --accept-dns is on, and pulls them
  # back out when it stops. Pinning them with mkBefore instead left every
  # lookup waiting on a dead 100.100.100.100 whenever tailscale was down.
}

{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";

    # cluster advertises 192.168.1.0/24 -- this very LAN -- as a subnet
    # route, so accepting routes sends desktop<->htpc traffic (Sunshine,
    # ssh, deploys) around through the tunnel instead of over the switch.
    # Nothing useful is behind those routes for a box already on the LAN.
    extraSetFlags = [ "--accept-routes=false" ];
  };

  # No static nameservers here: tailscaled installs 100.100.100.100 and the
  # tailnet search domain itself while --accept-dns is on, and pulls them
  # back out when it stops. Pinning them with mkBefore instead left every
  # lookup waiting on a dead 100.100.100.100 whenever tailscale was down.
}

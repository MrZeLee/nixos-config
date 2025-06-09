{
  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
  };

  # Enables ipp
  services.avahi.enable = true;

  # For scanning
  services.scanservjs = {
    enable = true;
    settings = {
      port = 8081;
    };
  };
}

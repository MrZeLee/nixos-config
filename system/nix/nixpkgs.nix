{
  self,
  inputs,
  ...
}: {
  nixpkgs = {
    config.allowUnfree = true;
  };
}

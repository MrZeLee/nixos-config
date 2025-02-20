{
  lib,
  pkgs,
  ...
}:
pkgs.buildGoModule rec {
  pname = "fleetcli";
  version = "0.11.3";

  src = pkgs.fetchFromGitHub {
    owner = "rancher";
    repo = "fleet";
    rev = "v${version}";
    sha256 = "sha256-vsm6HD8ThE0TkKzt6aHBGIge9EJViVGQ5rY4iX+wu5U=";
  };

  goModVendor = true;

  vendorHash = "sha256-RZp6zfBG8eseMPtEUSKeCpBL3vKjFLuYvUEo2eeB+gc=";

  testSrc = pkgs.fetchFromGitHub {
    owner = "rancher";
    repo = "fleet-examples";
    rev = "dcf4917293ef131f64724d0c03cadc4f5b257168";
    sha256 = "sha256-le0+a0uHXn4PnZ2avFXb2lcshjNL6YN4Cm6ReLUSlHs=";
  };

  nativeBuildInputs = [pkgs.git];
  # buildInputs = [ pkgs.git ];

  buildPhase = ''
    ldflags="-s -w \
    -X github.com/rancher/fleet/pkg/version.Version=${version} \
      -X github.com/rancher/fleet/pkg/version.GitCommit=unknown"
      go build -o ${placeholder "out"}/bin/fleet -ldflags "$ldflags" ./cmd/fleetcli
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp fleet $out/bin/
  '';

  checkPhase = ''
    # Uncomment below to skip tests
    echo "Skipping tests"; exit 0;

    cp -r ${testSrc} fleet-examples
    result=$(./fleet test fleet-examples/simple 2>&1 || true)
    echo "$result" | grep "kind: Deployment"
    versionOutput=$(./fleet --version)
    echo "$versionOutput" | grep "${version}"
  '';

  meta = with pkgs.lib; {
    description = "Manage large fleets of Kubernetes clusters";
    homepage = "https://github.com/rancher/fleet";
    license = licenses.asl20;
  };
}

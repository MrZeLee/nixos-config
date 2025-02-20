{
  lib,
  pkgs,
}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "koji";
  version = "3.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "cococonscious";
    repo = "koji";
    rev = "v${version}";
    sha256 = "sha256-v2TptHCnVFJ9DLxki7GP815sosCnDStAzZw7B4g/3mk=";
  };

  cargoHash = "sha256-posT6wp33Tj2bisuYsoh/CK9swS+OVju5vgpj4bTrYs=";

  nativeBuildInputs = with pkgs; [pkg-config cmake];
  buildInputs = with pkgs; [libgit2 openssl];

  meta = with lib; {
    description = "A tool to help create conventional git commits";
    homepage = "https://github.com/koji/koji";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}

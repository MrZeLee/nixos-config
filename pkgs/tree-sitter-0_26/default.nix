{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  rustPlatform,
  which,
  installShellFiles,
  buildPackages,
  substitute,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tree-sitter";
  version = "0.26.8";

  src = fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fcFEfoALrbpBD6rWogxJ7FNVlvDQgswoX9ylRgko+8Q=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-9FeWnWWPUWmMF15Psmul8GxGv2JceHWc2WZPmOr81gw=";

  buildInputs = [
    installShellFiles
  ];

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    which
  ];

  patches = [
    (substitute {
      src = ./remove-web-interface.patch;
    })
    (fetchpatch {
      name = "feat: allow `-` in grammar names";
      url = "https://github.com/tree-sitter/tree-sitter/commit/7d3c32125379c1dc02f47277bcd4eceaac299bdb.diff";
      hash = "sha256-ZNjdNateHVHDy0/txlAW8TUdz+DVxLKXpw8ojZbIQS8=";
    })
  ];

  postInstall = ''
    PREFIX=$out make install

    mv docs/src/assets/schemas/config.schema.json $out/
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd tree-sitter \
      --bash <("$out/bin/tree-sitter" complete --shell bash) \
      --zsh <("$out/bin/tree-sitter" complete --shell zsh) \
      --fish <("$out/bin/tree-sitter" complete --shell fish)
  '';

  doCheck = false;

  meta = {
    homepage = "https://github.com/tree-sitter/tree-sitter";
    description = "Parser generator tool and an incremental parsing library (pinned 0.26.x CLI)";
    mainProgram = "tree-sitter";
    changelog = "https://github.com/tree-sitter/tree-sitter/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
})
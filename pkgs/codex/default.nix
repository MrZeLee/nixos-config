{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  openssl,
  versionCheckHook,
  # Git is required for end-to-end tests that initialize temp repositories
  git,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "codex";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${finalAttrs.version}";
    hash = "sha256-ukQG6Ugc4lvJEdPmorNEdVh8XrgjuOO8x/8F+9jcw3U=";
  };

  sourceRoot = "${finalAttrs.src.name}/codex-rs";

  # Replace hardcoded 0.0.0 version in mcp-server tests with the actual build version
  postPatch = ''
    substituteInPlace mcp-server/tests/common/mcp_process.rs \
      --replace '"version": "0.0.0"' '"version": env!("CARGO_PKG_VERSION")'
  '';

  useFetchCargoVendor = true;
  cargoHash = "sha256-YZHmMRwJgZTPHyoB4GXlt6H2Igw1wh/4vMYt7+3Nz1Y=";

  nativeBuildInputs = [
    pkg-config
    # Git binary needed for e2e tests (git init, etc.)
    git
  ];
  buildInputs = [
    openssl
  ];

  checkFlags = [
    "--skip=keeps_previous_response_id_between_tasks" # Requires network access
    "--skip=retries_on_early_close" # Requires network access
    # Skip Landlock sandbox tests on NixOS (user namespaces or Landlock may be unavailable)
    "--skip=test_dev_null_write"
    "--skip=test_timeout"
    "--skip=test_writable_root"
    "--skip=test_root_read"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "^rust-v(\\d+\\.\\d+\\.\\d+)$"
      ];
    };
  };

  meta = {
    description = "Lightweight coding agent that runs in your terminal";
    homepage = "https://github.com/openai/codex";
    changelog = "https://raw.githubusercontent.com/openai/codex/refs/tags/rust-v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    mainProgram = "codex";
    maintainers = with lib.maintainers; [
      malo
      delafthi
    ];
    platforms = lib.platforms.unix;
  };
})

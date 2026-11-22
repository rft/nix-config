{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  python3,
}:

buildNpmPackage (finalAttrs: {
  pname = "actual-mcp";
  # Each release pins one exact @actual-app/api. That library downloads the
  # budget and runs Actual's own migrations on it, so it must not be newer than
  # the Actual server (and the web client it serves), or the budget file is
  # migrated past what the browser can open. 1.12.0 pins 26.7.0;
  # services.hermes-agent asserts the match against services.actual.package,
  # so a nixpkgs bump of Actual fails eval until this is bumped with it.
  version = "1.12.0";
  passthru.actualApiVersion = "26.7.0";

  src = fetchFromGitHub {
    owner = "s-stefanov";
    repo = "actual-mcp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4VlgFDFKF5mDy7QraR9Ids4a4abi+69jw135PdK9C/M=";
  };

  npmDepsHash = "sha256-5vB7vfI9zpDKXdPq0xhT7ZrqTZa+738BFHVT3YDKjP0=";

  # better-sqlite3 (via @actual-app/api) falls back from its prebuilt-binary
  # download, which the sandbox blocks, to a node-gyp build.
  nativeBuildInputs = [ python3 ];

  meta = {
    description = "MCP server for Actual Budget (read-only unless started with --enable-write)";
    homepage = "https://github.com/s-stefanov/actual-mcp";
    license = lib.licenses.mit;
    mainProgram = "actual-mcp";
    platforms = lib.platforms.linux;
  };
})

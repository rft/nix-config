{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ai-usagebar";
  version = "1.25.0";

  src = fetchFromGitHub {
    owner = "akitaonrails";
    repo = "ai-usagebar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wDswxfXcMONs8zzwKuzLM21s1OLoERtvikqsAndDt5U=";
  };

  cargoHash = "sha256-Ik0NdjzTA2L4tvrY8pg7P4YymL7I81wA3upW8nGmUvg=";

  # Only the CLI is needed (the noctalia ai-usagebar plugin runs
  # `ai-usagebar usage --json`); the tray is macOS/Windows-only.
  cargoBuildFlags = [
    "--bin"
    "ai-usagebar"
    "--bin"
    "ai-usagebar-tui"
  ];

  # Tests hit mocked HTTP servers and snapshot files; not worth running here.
  doCheck = false;

  meta = {
    description = "Multi-provider AI plan usage tracker (CLI + TUI)";
    homepage = "https://github.com/akitaonrails/ai-usagebar";
    license = lib.licenses.mit;
    mainProgram = "ai-usagebar";
    platforms = lib.platforms.linux;
  };
})

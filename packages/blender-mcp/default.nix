{
  lib,
  python3Packages,
  fetchgit,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "blender-mcp";
  version = "1.0.3";
  pyproject = true;

  src = fetchgit {
    url = "https://projects.blender.org/lab/blender_mcp.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pYeByO4Oi5eyynsJhGVd1vBWXHvhGn+Y5LGit6Kazlw=";
  };

  # The MCP server lives in mcp/; the Blender add-on it talks to is in addon/.
  sourceRoot = "${finalAttrs.src.name}/mcp";

  build-system = [ python3Packages.setuptools ];

  dependencies =
    with python3Packages;
    [
      docutils
      mcp
      pyyaml
    ]
    ++ mcp.optional-dependencies.cli;

  # Ship the add-on alongside the server so both always come from the same
  # release (linked into Blender's extensions dir by applications.creative).
  postInstall = ''
    mkdir -p $out/share/blender-mcp
    cp -r ../addon/blender_mcp_addon $out/share/blender-mcp/addon
  '';

  # The server spawns `blender` for its *_for_cli tools. MCP clients wrapped with
  # their own LD_LIBRARY_PATH (claude-code from unstable prefixes an alsa-lib
  # built against a newer glibc) would otherwise leak it into Blender, which then
  # fails to load with a GLIBC version mismatch.
  makeWrapperArgs = [
    "--unset"
    "LD_LIBRARY_PATH"
  ];

  # Tests need a running Blender instance.
  doCheck = false;

  pythonImportsCheck = [ "blmcp" ];

  meta = {
    description = "Official Blender Lab MCP server (stdio server + Blender add-on)";
    homepage = "https://www.blender.org/lab/mcp-server/";
    license = lib.licenses.gpl3Plus;
    mainProgram = "blender-mcp";
  };
})

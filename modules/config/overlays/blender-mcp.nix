{ delib, ... }:
delib.overlayModule {
  name = "blender-mcp";
  # Not in nixpkgs — official Blender Lab MCP server plus its Blender add-on.
  overlay = _final: prev: {
    blender-mcp = prev.callPackage ../../../packages/blender-mcp { };
  };
}

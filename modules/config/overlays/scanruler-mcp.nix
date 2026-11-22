{ delib, ... }:
delib.overlayModule {
  name = "scanruler-mcp";
  # Not in nixpkgs — MCP helper for the hosted ScanRuler app (scanruler.com).
  overlay = _final: prev: {
    scanruler-mcp = prev.callPackage ../../../packages/scanruler-mcp { };
  };
}

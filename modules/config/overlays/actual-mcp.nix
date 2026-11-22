{ delib, ... }:
delib.overlayModule {
  name = "actual-mcp";
  # Not in nixpkgs — Actual Budget MCP server, used by services.hermes-agent.
  overlay = _final: prev: {
    actual-mcp = prev.callPackage ../../../packages/actual-mcp { };
  };
}

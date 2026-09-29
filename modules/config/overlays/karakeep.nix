{ delib, ... }:
delib.overlayModule {
  name = "karakeep";
  # Build karakeep against Node 22 instead of the default Node 24.
  #
  # Node 24.19.0 backported per-object cleanup hooks into the header-only
  # node::ObjectWrap (its destructor now calls RemoveEnvironmentCleanupHook via
  # Isolate::GetCurrent()) but not the runtime-side global hook registry that
  # makes that call safe with no live Environment. karakeep 0.32.0 bundles
  # better-sqlite3 11.3.0, whose Statement/Database derive from node::ObjectWrap
  # and are compiled from source against these headers, so whenever GC
  # finalizes a Statement, node asserts `(env) != nullptr` and SIGABRTs.
  # On bristlecone this took down karakeep-workers (from 2026-09-14) and
  # karakeep-web (2026-09-28). Node 22.23.2's node_object_wrap.h has no
  # cleanup hooks, so it's unaffected.
  #
  # Drop this override once EITHER:
  #   - nixpkgs' nodejs_24 includes nodejs/node#65042 ("[v24.x backport] src:
  #     keep global list of addon-provided cleanup hooks"), or
  #   - nixpkgs' karakeep bundles better-sqlite3 >= 13 (N-API, no node::ObjectWrap).
  # Check the bundled version with
  # `grep '"version"' <karakeep>/lib/karakeep/node_modules/better-sqlite3/package.json`,
  # then remove the override and confirm
  # karakeep-web/karakeep-workers stay up.
  overlay = _final: prev: {
    karakeep = prev.karakeep.override { nodejs = prev.nodejs_22; };
  };
}

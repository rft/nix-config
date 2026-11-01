{ delib, inputs, ... }:
delib.overlayModule {
  name = "oh-my-pi";
  # Not in nixpkgs — use numtide/llm-agents.nix's from-source build (served by
  # cache.numtide.com) as pkgs.oh-my-pi.
  overlay = final: prev: {
    oh-my-pi =
      let
        omp = inputs.llm-agents.packages.${final.stdenv.hostPlatform.system}.omp;
        # `omp plugin install` shells out to bun (npm: specs) and git (git:
        # specs); installed plugins then run under node, and some ship helper
        # scripts that need python3 (e.g. engram's engram.py). The wrapper
        # exports PATH rather than rewriting argv, so omp's self-re-exec for
        # subagents inherits it too.
        runtimeDeps = with prev; [
          bun
          nodejs
          git
          python3
        ];
      in
      prev.symlinkJoin {
        name = "omp-${omp.version}";
        inherit (omp) version meta;
        paths = [ omp ];
        nativeBuildInputs = [ prev.makeBinaryWrapper ];
        postBuild = ''
          wrapProgram $out/bin/omp --prefix PATH : ${prev.lib.makeBinPath runtimeDeps}
        '';
      };
  };
}

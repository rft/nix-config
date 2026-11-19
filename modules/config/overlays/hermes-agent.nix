{ delib, inputs, ... }:
delib.overlayModule {
  name = "hermes-agent";
  # Nous Research's Hermes Agent, from numtide/llm-agents.nix (served by
  # cache.numtide.com, like pkgs.oh-my-pi) as pkgs.hermes-agent.
  overlay = final: _prev: {
    inherit (inputs.llm-agents.packages.${final.stdenv.hostPlatform.system}) hermes-agent;
  };
}

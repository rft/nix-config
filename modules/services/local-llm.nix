{
  delib,
  lib,
  pkgs,
  ...
}:
let
  port = 8090;

  # Inkling 2 Mini (Thinking Machines' looped MoE) needs llama.cpp b12600+,
  # and b12628 fixes its loop slots; nixpkgs is still on v1.0.0 (b12359).
  # Drop this override once nixpkgs' llama-cpp passes b12628.
  #
  # The web UI moved from tools/ui to an npm workspace under ui/ that the
  # nixpkgs recipe doesn't know, so build the API server without it — 9router
  # is the only client.
  llama-cpp = pkgs.llama-cpp.overrideAttrs (
    finalAttrs: prev: {
      version = "b12635";
      src = pkgs.fetchFromGitHub {
        owner = "ggml-org";
        repo = "llama.cpp";
        tag = finalAttrs.version;
        hash = "sha256-8xeGq+8goyknGXSy7rmuHB8/Ksj6emaku/5pa7AVLFQ=";
      };
      # by name: llama-cpp comes from the unstable set, so pkgs.npmHooks differs
      nativeBuildInputs = lib.filter (p: (p.name or "") != "npm-config-hook") prev.nativeBuildInputs;
      npmDeps = null;
      preConfigure = "";
      cmakeFlags = prev.cmakeFlags ++ [
        (lib.cmakeBool "LLAMA_BUILD_UI" false)
        (lib.cmakeBool "LLAMA_USE_PREBUILT_UI" false)
        # nixpkgs hardcodes v1.0.0's build info; the later -D wins
        (lib.cmakeFeature "LLAMA_BUILD_NUMBER" "12635")
        (lib.cmakeFeature "LLAMA_BUILD_COMMIT" "ad50351")
      ];
    }
  );
in
delib.module {
  name = "services.local-llm";

  options = delib.singleEnableOption false;

  myconfig.always =
    { myconfig, ... }:
    {
      services.local-llm.enable = lib.mkDefault (myconfig.services.enable or false);
    };

  nixos.ifEnabled = {
    # Local Inkling 2 Mini on the CPU, registered in 9router (services.ai-gateway)
    # as an openai-compatible provider so agents reach it through the gateway.
    # llama-server has no auth, so it listens on loopback only — the mesh goes
    # through 9router.
    #
    # The ~18GB GGUF is pulled from Hugging Face into LLAMA_CACHE
    # (/var/cache/llama-cpp) on first start; it is not backed up.
    services.llama-cpp = {
      enable = true;
      package = llama-cpp;
      host = "127.0.0.1";
      inherit port;
      extraFlags = [
        "-hf"
        "ggml-org/Inkling-2-Mini-GGUF:IQ4_NL"
        "--alias"
        "inkling-2-mini"
        # chat template (tool calls, reasoning effort) lives in the GGUF
        "--jinja"
        "-c"
        "65536"
        # one slot: a single agent at a time, and its prompt cache stays warm
        "-np"
        "1"
        # the model card reports reasoning loops — cap a runaway reply
        "-n"
        "8192"
        # neutral sampling, as in the published llama.cpp benchmarks; the
        # chat template sets the reasoning effort (default 0.9)
        "--temp"
        "1.0"
        "--top-p"
        "1.0"
        "--top-k"
        "0"
        "--min-p"
        "0.0"
      ];
    };
  };
}

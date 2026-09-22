{
  lib,
  pkgs,
  stdenvNoCC,
  fetchurl,
  makeBinaryWrapper,
}:

let
  version = "18.2.9";

  # Upstream is a bun monorepo with napi-rs natives, puppeteer and
  # transformers.js — building it from source is not practical, so use the
  # prebuilt single-file executables from the GitHub release.
  sources = {
    x86_64-linux = {
      asset = "omp-linux-x64";
      hash = "sha256-fee+ZxvyfVoqFf/3kUkOMZ/txZ5esXWc6iBg4ULAhuw=";
    };
    aarch64-linux = {
      asset = "omp-linux-arm64";
      hash = "sha256-xFXSZbqyJ9Je566MHhtaINKTVP+R0v5zHWEuFANHzS0=";
    };
    aarch64-darwin = {
      asset = "omp-darwin-arm64";
      hash = "sha256-QvDpcqNVB5qrejXyp0/nvztG1QDUSqh2dwrSuKH1UG4=";
    };
    x86_64-darwin = {
      asset = "omp-darwin-x64";
      hash = "sha256-h/NX+bsiycTBsC2U/oWZbZXyjbO3WlMEDllzM5G1lH0=";
    };
  };

  inherit (stdenvNoCC.hostPlatform) system;

  # `omp plugin install` shells out to bun (npm: specs) and git (git: specs);
  # installed plugins then run under node, and some ship helper scripts that
  # need python3 (e.g. engram's engram.py).
  runtimeDeps = with pkgs; [
    bun
    nodejs
    git
    python3
  ];

  source = sources.${system} or (throw "oh-my-pi: no prebuilt binary for ${system}");

  meta = {
    description = "AI coding agent for the terminal, built on Pi";
    homepage = "https://omp.sh";
    license = lib.licenses.mit;
    mainProgram = "omp";
    platforms = lib.attrNames sources;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };

  unwrapped = stdenvNoCC.mkDerivation {
    pname = "oh-my-pi-unwrapped";
    inherit version meta;

    src = fetchurl {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/${source.asset}";
      inherit (source) hash;
    };

    dontUnpack = true;

    # Deliberately no autoPatchelfHook: this is a `bun build --compile`
    # executable whose JS payload is appended after the ELF and located by
    # absolute file offsets. patchelf grows the ELF, invalidating those offsets,
    # and the binary then silently degrades into a plain `bun` REPL. The Linux
    # build is instead run inside an FHS env that supplies a real
    # /lib64/ld-linux-x86-64.so.2; Darwin needs no wrapping at all.
    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/bin/omp
      runHook postInstall
    '';
  };
in
if stdenvNoCC.hostPlatform.isDarwin then
  # No FHS env on Darwin, so put the runtime deps on PATH with a wrapper. The
  # wrapper exports PATH rather than rewriting argv, so omp's self-re-exec for
  # subagents inherits it too.
  stdenvNoCC.mkDerivation {
    pname = "omp";
    inherit version meta;

    dontUnpack = true;
    nativeBuildInputs = [ makeBinaryWrapper ];

    installPhase = ''
      runHook preInstall
      makeWrapper ${unwrapped}/bin/omp $out/bin/omp \
        --prefix PATH : ${lib.makeBinPath runtimeDeps}
      runHook postInstall
    '';
  }
else
  # omp re-execs itself for subagents and resolves its own path via
  # /proc/self/exe, so it has to run as the actual process — a loader wrapper
  # (`ld-linux ... omp`) would leave execPath pointing at the loader.
  pkgs.buildFHSEnv {
    # Named after the binary so the FHS wrapper lands on $out/bin/omp, matching
    # the Darwin build.
    pname = "omp";
    inherit version meta;

    targetPkgs =
      p: [
        unwrapped
        p.cacert
        p.zlib
      ]
      ++ runtimeDeps;

    runScript = "omp";
  }

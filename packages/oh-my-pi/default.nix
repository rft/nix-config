{
  lib,
  pkgs,
  stdenvNoCC,
  fetchurl,
}:

let
  version = "17.3.5";

  # Upstream is a bun monorepo with napi-rs natives, puppeteer and
  # transformers.js — building it from source is not practical, so use the
  # prebuilt single-file executables from the GitHub release.
  sources = {
    x86_64-linux = {
      asset = "omp-linux-x64";
      hash = "sha256-YFtKijoTdImpHVnnAoxB86/yAWnzUpArQQifv9+KJTw=";
    };
    aarch64-linux = {
      asset = "omp-linux-arm64";
      hash = "sha256-x5q6SFnXHm6teXvtL1EKnel8nVdq+YQuf+Y9vJ9BV68=";
    };
    aarch64-darwin = {
      asset = "omp-darwin-arm64";
      hash = "sha256-phVKSgS3j5FB4NMNUDUoRQPy+gNFILZN/aWFYVqM+0o=";
    };
    x86_64-darwin = {
      asset = "omp-darwin-x64";
      hash = "sha256-yyCbDi6sLZdpgMyg6s4cJRPuEkDJgbfRP7Z035Lj/3o=";
    };
  };

  inherit (stdenvNoCC.hostPlatform) system;

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
  unwrapped
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
      p: with p; [
        unwrapped
        cacert
        zlib
      ];

    runScript = "omp";
  }

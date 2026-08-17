{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  electron,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "circuitjs1";
  # Upstream publishes no tagged releases and the offline builds live at a
  # fixed, unversioned URL, so the version tracks the file's upload date.
  # Bump the date and the hash together when refreshing.
  version = "0-unstable-2026-08-02";

  # The GWT-compiled web app under war/circuitjs1 is not checked into the
  # upstream repo (gradle + the GWT compiler produce it), so the prebuilt
  # offline bundle is the only practical source. Only resources/app is used —
  # it is plain HTML/JS — and it runs on nixpkgs' electron instead of the
  # chromium the bundle ships.
  src = fetchurl {
    url = "https://www.falstad.com/circuit/offline/circuitjs1-linux64.tgz";
    hash = "sha256-oVH+LVSggGKtaIkVZK05Ctyf7euLTlsQzSOY6cfX3HE=";
  };

  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/circuitjs1
    tar -xzf $src -C $out/share/circuitjs1 --strip-components=3 \
      --warning=no-unknown-keyword circuitjs1/resources/app

    # The bundle is packed on macOS and carries AppleDouble sidecars.
    find $out/share/circuitjs1 -name '._*' -delete

    install -Dm644 $out/share/circuitjs1/war/icon512.png \
      $out/share/icons/hicolor/512x512/apps/circuitjs1.png

    makeWrapper ${lib.getExe electron} $out/bin/circuitjs1 \
      --add-flags $out/share/circuitjs1 \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "circuitjs1";
      desktopName = "CircuitJS1";
      comment = "Interactive electronic circuit simulator";
      exec = "circuitjs1 %f";
      icon = "circuitjs1";
      categories = [
        "Education"
        "Science"
        "Electronics"
      ];
      startupWMClass = "Circuit JS1";
    })
  ];

  meta = {
    description = "Falstad's interactive electronic circuit simulator";
    homepage = "https://www.falstad.com/circuit/";
    license = lib.licenses.gpl2Plus;
    mainProgram = "circuitjs1";
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
  };
})

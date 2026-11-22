{
  lib,
  buildNpmPackage,
  fetchurl,
  makeWrapper,
  nodejs_24,
}:

buildNpmPackage (finalAttrs: {
  pname = "scanruler-mcp";
  version = "0.6.4";

  # Plain JS, no build step — the npm tarball is the whole package.
  src = fetchurl {
    url = "https://registry.npmjs.org/scanruler-mcp/-/scanruler-mcp-${finalAttrs.version}.tgz";
    hash = "sha256-xeFhbuFiTJ+dQzBm5Hnziz6AxBCAqOIXSfeUv160fGg=";
  };

  nodejs = nodejs_24;

  # The published tarball has no lockfile. package-lock.json here was generated
  # with `npm install --package-lock-only --ignore-scripts` against the tarball's
  # package.json — regenerate it the same way on version bumps.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-SFNG8CyPkFdN88xhlj6Sa1ncclryyRs4AFHNgefXMUM=";

  dontNpmBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  # The server otherwise fetches newer releases from npm into its cache and
  # runs those on the next start, bypassing the version pinned here.
  postFixup = ''
    wrapProgram $out/bin/scanruler-mcp --set SCANRULER_MCP_NO_UPDATE 1
  '';

  meta = {
    description = "MCP server that lets AI agents drive ScanRuler, the in-browser 3D-scan measuring tool";
    homepage = "https://scanruler.com/";
    license = lib.licenses.agpl3Only;
    mainProgram = "scanruler-mcp";
    platforms = lib.platforms.unix;
  };
})

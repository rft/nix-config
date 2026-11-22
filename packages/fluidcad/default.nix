{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  nodejs_24,
}:

buildNpmPackage (finalAttrs: {
  pname = "fluidcad";
  version = "0.0.52";

  # The npm tarball ships the prebuilt lib/server/ui/mcp bundles, so there is
  # nothing to compile — building the GitHub monorepo would need its full
  # TypeScript/Vite toolchain for no gain.
  src = fetchurl {
    url = "https://registry.npmjs.org/fluidcad/-/fluidcad-${finalAttrs.version}.tgz";
    hash = "sha256-2I0LObcghwI89MLTMTjyI1dkfzV7y9oRRe13uEXLUVY=";
  };

  nodejs = nodejs_24;

  # The published tarball has no lockfile. package-lock.json here was generated
  # with `npm install --package-lock-only --ignore-scripts` against the tarball's
  # package.json minus devDependencies/scripts (build-only tooling) — regenerate
  # it the same way on version bumps.
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies, .scripts)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-eAwGGCfPffTI96ieIuVcGdy+adyjxCw7VmBw7b59GNQ=";

  dontNpmBuild = true;

  meta = {
    description = "Code-driven parametric CAD on the OpenCascade kernel, with live preview";
    homepage = "https://github.com/fluid-cad/fluidcad";
    license = lib.licenses.mit;
    mainProgram = "fluidcad";
    platforms = lib.platforms.unix;
  };
})

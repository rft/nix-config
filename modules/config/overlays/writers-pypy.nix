{ delib, ... }:
delib.overlayModule {
  name = "writers-pypy";
  # Backport of the upstream fix to writers.makePythonWriter.
  #
  # nixpkgs 26.05 still guards the chosen interpreter with
  #   `pythonPackages != pkgs.pypy2Packages || pythonPackages != pkgs.pypy3Packages`
  # (pkgs/build-support/writers/scripts.nix). Both sides of that `||` are always
  # true — a set cannot equal two different sets — so the guard is dead code, but
  # evaluating it deep-compares against the pypy package sets. Those sets share
  # attribute names with python3Packages, so Nix is forced to evaluate every pypy
  # derivation, which then trips on pypy2's insecure setuptools/pip on x86_64 and
  # on pypy being unsupported on i686 (pulled in by 32-bit graphics on desktops).
  # Net effect: anything reaching writePython3 fails to evaluate — including
  # fetch-cargo-vendor-util, and therefore every Rust package.
  #
  # unstable dropped the guard outright, leaving just the `libraries == [ ]`
  # check; this rewrites the condition to `true`, which is exactly equivalent.
  # The substitution no-ops if the line ever changes, so this overlay simply
  # stops doing anything once the fix lands on the 26.05 branch — at which point
  # delete this file.
  overlay =
    _final: prev:
    let
      original = builtins.readFile "${prev.path}/pkgs/build-support/writers/scripts.nix";
      patched =
        builtins.replaceStrings
          [ "if pythonPackages != pkgs.pypy2Packages || pythonPackages != pkgs.pypy3Packages then" ]
          [ "if true then" ]
          original;
    in
    prev.lib.optionalAttrs (patched != original) {
      writers = prev.writers // prev.callPackages (builtins.toFile "writers-scripts.nix" patched) { };
    };
}

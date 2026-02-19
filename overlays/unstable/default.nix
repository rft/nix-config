{ inputs, ... }:
final: prev:
let
  unstable = inputs.nixpkgs-unstable.legacyPackages.${final.system};
in
{
  # VSCodium from 24.11 is too old for latest vscode extensions.
  inherit (unstable) vscodium;
  # inherit (unstable) xonsh;
  inherit (unstable) helix;
  inherit (unstable) claude-code;
  inherit (unstable) codex;
  inherit (unstable) kando;
}

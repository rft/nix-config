{
  channels,
  ...
}:

final: prev: {
  # VSCodium from 24.11 is too old for latest vscode extensions.
  inherit (channels.nixpkgs-unstable) vscodium;
  inherit (channels.nixpkgs-unstable) xonsh;
  inherit (channels.nixpkgs-unstable) helix;
}

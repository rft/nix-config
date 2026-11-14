# xonsh's Python environment: the xontribs everywhere, plus the shared
# data-science set unless `full = false` (servers, see core.workstation).
{
  full ? true,
}:
ps:
(if full then import ./python-core-packages.nix ps else [ ])
++ [
  # xonsh-specific extras
  # Looks like the only ones available right now are
  # nix repl github:NixOS/nixpkgs
  # nix repl github:nixos/nixpkgs/nixos-unstable
  # legacyPackages.x86_64-linux.xonsh.xontribs
  ps.xonsh.xontribs.xontrib-vox
  ps.xonsh.xontribs.xonsh-direnv
  ps.xonsh.xontribs.xontrib-whole-word-jumping
  ps.xonsh.xontribs.xontrib-bashisms
]

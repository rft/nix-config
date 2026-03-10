{ delib, pkgs, ... }:
delib.module {
  name = "core.xonsh";

  nixos.always =
  let
    xonshExtraPackages = import ../../lib/xonsh-extra-packages.nix;
  in
  {
    programs.xonsh = {
      enable = true;
      extraPackages = xonshExtraPackages;
    };
  };
}

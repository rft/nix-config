{ delib, pkgs, ... }:
let
  xonshExtraPackages = import ../../lib/xonsh-extra-packages.nix;
in
delib.module {
  name = "core.xonsh";

  nixos.always =
    { myconfig, ... }:
    {
      programs.xonsh = {
        enable = true;
        extraPackages = xonshExtraPackages { full = myconfig.core.workstation.enable; };
      };
    };

  darwin.always =
    { myconfig, ... }:
    {
      environment.systemPackages = [
        (pkgs.xonsh.override {
          extraPackages = xonshExtraPackages { full = myconfig.core.workstation.enable; };
        })
      ];
    };
}

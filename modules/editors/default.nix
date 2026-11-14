{ delib, lib, ... }:
delib.module {
  name = "editors";

  options = delib.singleEnableOption false;

  # GUI editors follow core.workstation, so servers and the installer ISO
  # skip them unless a host asks.
  myconfig.always =
    { myconfig, ... }:
    {
      editors.enable = lib.mkDefault myconfig.core.workstation.enable;
    };
}

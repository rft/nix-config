{ delib, ... }:
delib.module {
  name = "nixos-modules";

  nixos.always = {
    imports = [
      ../nixos/applications
      ../nixos/archiving
      ../nixos/core
      ../nixos/desktop
      ../nixos/programming
      ../nixos/services
    ];
  };
}

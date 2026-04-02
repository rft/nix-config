{
  delib,
  inputs,
  lib,
  ...
}:
delib.module {
  name = "security";

  options = delib.singleEnableOption false;

  nixos.always.imports = [
    inputs.nix-mineral.nixosModules.nix-mineral

    # nix-mineral references services.resolved.settings which doesn't exist
    # in NixOS 25.11 yet — define it here so the module can be imported
    ({ lib, ... }: {
      options.services.resolved.settings = lib.mkOption {
        type = lib.types.anything;
        default = {};
        description = "Shim for nix-mineral compatibility";
      };
    })
  ];

  # Disable dnssec by default as it requires services.resolved.settings
  nixos.always = {
    nix-mineral.settings.misc.dnssec = false;
  };

  nixos.ifEnabled = {
    # Enable nix-mineral with default preset
    nix-mineral = {
      enable = true;

      # Extras: opt-in hardening from maximum preset
      extras = {
        system = {
          lock-root = true;
          minimize-swapping = true;
          secure-chrony = true;
        };
        misc = {};
        network = {
          bluetooth-kmodules = true;
          tcp-window-scaling = true;
        };
      };

};
  };
}

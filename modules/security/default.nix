{
  delib,
  inputs,
  ...
}:
delib.module {
  name = "security";

  options = delib.singleEnableOption false;

  nixos.always.imports = [
    inputs.nix-mineral.nixosModules.nix-mineral
  ];

  # nix-mineral turns this into services.resolved.settings.Resolve.DNSSEC.
  # 26.05 defines that option natively (25.11 did not, which is why this used
  # to need a shim), so this is now a deliberate opt-out rather than a
  # compatibility workaround — flip it to true to actually enforce DNSSEC.
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

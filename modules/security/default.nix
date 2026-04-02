{
  delib,
  inputs,
  ...
}:
delib.module {
  name = "security";

  options = delib.singleEnableOption false;

  nixos.ifEnabled = {
    imports = [
      inputs.nix-mineral.nixosModules.nix-mineral
    ];

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

      # Block process memory modification
      settings.system.proc-mem-force = true;
    };
  };
}

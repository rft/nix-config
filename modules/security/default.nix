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

  nixos.ifEnabled =
    { myconfig, ... }:
    let
      ompDir = "/home/${myconfig.constants.username}/.omp";
      ompNatives = "${ompDir}/natives";
    in
    {
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
          misc = { };
          network = {
            bluetooth-kmodules = true;
            tcp-window-scaling = true;
          };
        };

        # oh-my-pi (modules/core) embeds its napi natives in the
        # `bun build --compile` binary and extracts them to
        # ~/.omp/natives/<version> on first run. nix-mineral mounts /home
        # noexec, so dlopen()ing those .node files fails with "failed to map
        # segment from shared object" and omp refuses to start. The natives are
        # not published as release assets, so they cannot be staged into the
        # store — punch the narrowest exec hole that fixes it instead of
        # relaxing all of /home.
        filesystems.normal.${ompNatives} = {
          enable = true;
          options = {
            noexec = false;
            exec = true;
          };
        };
      };

      # systemd creates the bind mount's target root-owned, which would leave
      # omp unable to extract into it; tmpfiles restores user ownership.
      systemd.tmpfiles.rules = [
        "d ${ompDir} 0755 ${myconfig.constants.username} users -"
        "d ${ompNatives} 0755 ${myconfig.constants.username} users -"
      ];
    };
}

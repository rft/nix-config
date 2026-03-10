{ delib, inputs, ... }:
delib.module {
  name = "desktop";

  options = delib.singleEnableOption false;

  nixos.always.imports = [ inputs.noctalia.nixosModules.default ];
  home.always.imports = [ inputs.noctalia.homeModules.default ];

  nixos.ifEnabled = { pkgs, ... }: {
    services.noctalia-shell = {
      enable = true;
      package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
  };

  home.ifEnabled = {
    programs.noctalia-shell = {
      enable = true;
      settings.colorSchemes.predefinedScheme = "Nord";
    };
  };
}

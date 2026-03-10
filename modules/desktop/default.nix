{ delib, inputs, pkgs, ... }:
delib.module {
  name = "desktop";

  options = delib.singleEnableOption false;

  nixos.always.imports = [ inputs.noctalia.nixosModules.default ];
  home.always.imports = [ inputs.noctalia.homeModules.default ];

  nixos.ifEnabled = {
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

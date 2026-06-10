{ delib, inputs, pkgs, ... }:
delib.module {
  name = "desktop";

  options = delib.singleEnableOption false;

  home.always.imports = [ inputs.noctalia.homeModules.default ];

  nixos.ifEnabled = {
    environment.systemPackages = [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };

  home.ifEnabled = {
    programs.noctalia = {
      enable = true;
      settings.theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Nord";
      };
    };
  };
}

{ delib, ... }:
delib.module {
  name = "applications.kdenlive";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    applications.kdenlive.enable = myconfig.applications.enable or false;
  };

  home.ifEnabled = { pkgs, ... }: {
    xdg.configFile."kdenlive/kdenlive.shortcuts".source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/BreadOnPenguins/dots/master/bread_kdenlive.shortcuts";
      sha256 = "09dh5sx2aj06djqlfk8ybj2q3j23aag0dzk5qi6r4wlq4pcyr33m";
    };
  };
}

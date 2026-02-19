{ delib, ... }:
delib.module {
  name = "home-modules";

  home.always = {
    imports = [
      ../home/nano
    ];
  };
}

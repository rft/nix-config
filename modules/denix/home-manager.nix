{ delib, inputs, ... }:
delib.module {
  name = "home-manager";

  nixos.always = {
    home-manager.extraSpecialArgs = {
      inherit inputs;
    };
  };
}

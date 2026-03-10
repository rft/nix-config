{ delib, ... }:
delib.module {
  name = "user";

  nixos.always = { myconfig, ... }: {
    users.users.${myconfig.constants.username} = {
      isNormalUser = true;
      description = myconfig.constants.username;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}

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
      openssh.authorizedKeys.keys = builtins.attrValues myconfig.constants.sshKeys;
    };

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  darwin.always = { myconfig, ... }: {
    users.users.${myconfig.constants.username} = {
      home = "/Users/${myconfig.constants.username}";
      description = myconfig.constants.username;
    };

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}

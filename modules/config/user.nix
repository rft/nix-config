{ delib, ... }:
let
  # numtide/llm-agents.nix (source of pkgs.oh-my-pi) builds from source; its
  # cache saves compiling omp's Rust natives on every host.
  substituters = [ "https://cache.numtide.com" ];
  trustedPublicKeys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
in
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
    nix.settings.extra-substituters = substituters;
    nix.settings.extra-trusted-public-keys = trustedPublicKeys;
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

    # Darwin hosts run Determinate Nix (nix.enable = false), so nix.settings is
    # inert there. Its nix.conf includes nix.custom.conf for user settings.
    environment.etc."nix/nix.custom.conf" = {
      text = ''
        extra-substituters = ${toString substituters}
        extra-trusted-public-keys = ${toString trustedPublicKeys}
      '';
      # The installer-written original, so nix-darwin may take it over.
      knownSha256Hashes = [ "3bd68ef979a42070a44f8d82c205cfd8e8cca425d91253ec2c10a88179bb34aa" ];
    };
  };
}

{ delib, lib, ... }:
delib.module {
  name = "constants";

  options.constants = with delib; {
    username = strOption "nano";
    userfullname = strOption "nano";
    useremail = strOption "nano@nomolabs.net";
    gitname = strOption "rft";
    sshKeys = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        lemon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIdtSRvR7Zcto/+lbuoYDkLitMEiB05X1GDFlW51DCz3 nano@nomolabs.net";
      };
    };
  };

  myconfig.always = { cfg, ... }: {
    args.shared.constants = cfg;
  };
}

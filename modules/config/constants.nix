{ delib, ... }:
delib.module {
  name = "constants";

  options.constants = with delib; {
    username = readOnly (strOption "nano");
    userfullname = readOnly (strOption "nano");
    useremail = readOnly (strOption "nano@nomolabs.net");
    gitname = readOnly (strOption "rft");
  };

  myconfig.always = { cfg, ... }: {
    args.shared.constants = cfg;
  };
}

{ delib, ... }:
delib.module {
  name = "constants";

  options.constants = with delib; {
    username = strOption "nano";
    userfullname = strOption "nano";
    useremail = strOption "nano@nomolabs.net";
    gitname = strOption "rft";
  };

  myconfig.always = { cfg, ... }: {
    args.shared.constants = cfg;
  };
}

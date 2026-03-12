{ delib, ... }:
delib.module {
  name = "home";

  home.always = { myconfig, ... }: {
    programs.home-manager.enable = true;

    home.username = myconfig.constants.username;
    home.homeDirectory = "/home/${myconfig.constants.username}";

    home.file.".claude/settings.json".text = builtins.toJSON {
      env = {
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
      };
      teammateMode = "auto";
    };

    home.sessionVariables = { };

    programs.git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          name = myconfig.constants.gitname;
          email = myconfig.constants.useremail;
        };
        pull.rebase = false;
      };
    };
  };
}

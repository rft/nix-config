{ delib, lib, pkgs, ... }:
delib.module {
  name = "home";

  home.always = { myconfig, ... }: {
    programs.home-manager.enable = true;

    home.username = lib.mkForce myconfig.constants.username;
    home.homeDirectory = lib.mkForce (
      if pkgs.stdenv.isDarwin
      then "/Users/${myconfig.constants.username}"
      else "/home/${myconfig.constants.username}"
    );

    # Claude Code settings.json is not managed by Nix because home.file creates
    # a read-only symlink to the Nix store, which prevents Claude Code from
    # persisting runtime state (model preference, recent activity, etc.).
    # Manage ~/.claude/settings.json manually instead.
    # home.file.".claude/settings.json".text = builtins.toJSON {
    #   env = {
    #     CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
    #   };
    #   teammateMode = "auto";
    # };

    home.sessionPath = [
      "$HOME/.local/bin"
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
    };

    programs.git = {
      enable = true;
      lfs.enable = true;
      settings = {
        core.editor = "nvim";
        user = {
          name = myconfig.constants.gitname;
          email = myconfig.constants.useremail;
        };
        pull.rebase = false;
        push.autoSetupRemote = true;
      };
    };
  };
}

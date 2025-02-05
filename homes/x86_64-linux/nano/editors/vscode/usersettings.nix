{pkgs, ...}: let
  general = {
    "vim.easymotion"= true;
    "vim.useSystemClipboard"= true;
    "vscode-pets.throwBallWithMouse"= true;
    "vim.normalModeKeyBindingsNonRecursive"= [
        {
          "before"= [
            "<space>"
          ];
          "commands"= [
            "vspacecode.space"
          ];
        }
        {
          "before"= [
            ","
          ];
          "commands"= [
            "vspacecode.space"
            {
              "command"= "whichkey.triggerKey";
              "args"= "m";
            }
          ];
        }
    ];
    "vim.visualModeKeyBindingsNonRecursive"= [
      {
        "before"= [
          "<space>"
        ];
        "commands"= [
         "vspacecode.space"
        ];
      }
      {
        "before"= [
          ","
        ];
        "commands"= [
          "vspacecode.space"
          {
            "command"= "whichkey.triggerKey";
            "args"= "m";
          }
        ];
      }
    ];
  };

  editor = {
    "editor.stickyScroll.enabled"= true;
    "editor.bracketPairColorization.enabled"= true;
    "editor.guides.bracketPairs"= "active";
    "editor.formatOnSave"= true;
    "editor.codeActionsOnSave"= {
      "source.fixAll"= "explicit";
    };
  };

  git = {
    "git.autofetch"= true;
    "git.confirmSync"= false;
  };

  languages = {
    "python.analysis.typeCheckingMode"= "strict";
  };

  in
    {
      programs.vscode.userSettings =
        general
        // editor
        // git
        // languages;
    }

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
    "editor.fontLigatures" = true;
    "editor.fontFamily" = "Fira Code";
  };

  git = {
    "git.autofetch"= true;
    "git.confirmSync"= false;
  };

  languages = {
    "python.analysis.typeCheckingMode" = "strict";
    "nix.serverPath" = "nixd";
    "nix.enableLanguageServer" = true;
    "nix.serverSettings" = {
      "nixd" = {
        "formatting" = {
          "command" = [ "nixfmt" ];
        };
      };
    };
  };

  in
    {
      # Note: to future me, remind yourselfe that the "//" is not a comment but actually combining these lol
      programs.vscode.userSettings =
        general
        // editor
        // git
        // languages;
    }

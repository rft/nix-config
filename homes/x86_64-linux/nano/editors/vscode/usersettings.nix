{
  pkgs,
  config,
  lib,
  ...
}:
let
  general = {
    "vim.easymotion" = true;
    "vim.useSystemClipboard" = true;
    "vscode-pets.throwBallWithMouse" = true;
    "chat.disableAIFeatures" = false;
    "vim.normalModeKeyBindingsNonRecursive" = [
      {
        "before" = [
          "<space>"
        ];
        "commands" = [
          "vspacecode.space"
        ];
      }
      {
        "before" = [
          ","
        ];
        "commands" = [
          "vspacecode.space"
          {
            "command" = "whichkey.triggerKey";
            "args" = "m";
          }
        ];
      }
    ];
    "vim.visualModeKeyBindingsNonRecursive" = [
      {
        "before" = [
          "<space>"
        ];
        "commands" = [
          "vspacecode.space"
        ];
      }
      {
        "before" = [
          ","
        ];
        "commands" = [
          "vspacecode.space"
          {
            "command" = "whichkey.triggerKey";
            "args" = "m";
          }
        ];
      }
    ];
  };

  editor = {
    "editor.stickyScroll.enabled" = true;
    "editor.bracketPairColorization.enabled" = true;
    "editor.guides.bracketPairs" = "active";
    "editor.formatOnSave" = true;
    "editor.codeActionsOnSave" = {
      "source.fixAll" = "explicit";
    };
    "editor.fontLigatures" = true;
    "editor.fontFamily" = "FiraCode Nerd Font Mono";
    "terminal.integrated.fontFamily" = "'FiraCode Nerd Font Mono'";
    "terminal.integrated.fontLigatures" = true;
  };

  git = {
    "git.autofetch" = true;
    "git.confirmSync" = false;
  };

  languages = {
    "nix.serverPath" = "nixd";
    "nix.enableLanguageServer" = true;
    "nix.serverSettings" = {
      "nixd" = {
        "formatting" = {
          "command" = [ "nixfmt" ];
        };
      };
    };
    "[nix]" = {
      "editor.defaultFormatter" = "brettm12345.nixfmt-vscode";
    };
    "[svelte]" = {
      "editor.defaultFormatter" = "svelte.svelte-vscode";
    };
    "svelte.enable-ts-plugin" = true;
    "svelte.ask-to-enable-ts-plugin" = false;

    "python.analysis.typeCheckingMode" = "strict";
    "python.defaultInterpreterPath" = "python";
    "python.linting.enabled" = true;
    "python.linting.pylintEnabled" = true;
    "python.formatting.provider" = "ruff";
    "python.analysis.autoImportCompletions" = true;
    "python.languageServer" = "Jedi";
    "python.analysis.extraPaths" = [ "\${workspaceFolder}" ];
    "python.autoComplete.extraPaths" = [ "\${workspaceFolder}" ];
  };

in
{
  config = lib.mkIf config.modules.home.editors.enable {
    # Note: to future me, remind yourselfe that the "//" is not a comment but actually combining these lol
    programs.vscode.profiles.default.userSettings = general // editor // git // languages;
  };
}

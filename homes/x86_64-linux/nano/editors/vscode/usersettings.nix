{ pkgs, ... }:
let
  general = {
    "vim.easymotion" = true;
    "vim.useSystemClipboard" = true;
    "vscode-pets.throwBallWithMouse" = true;
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
    "[nix]" = {
      "editor.defaultFormatter" = "brettm12345.nixfmt-vscode";
    };
    "[svelte]" = {
      "editor.defaultFormatter" = "svelte.svelte-vscode";
    };
    "svelte.enable-ts-plugin" = true;
    "svelte.ask-to-enable-ts-plugin" = false;
  };

in
{
  # Note: to future me, remind yourselfe that the "//" is not a comment but actually combining these lol
  programs.vscode.userSettings = general // editor // git // languages;
}

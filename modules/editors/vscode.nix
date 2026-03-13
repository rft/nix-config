{ delib, lib, pkgs, ... }:
delib.module {
  name = "editors.vscode";

  options = delib.singleEnableOption true;

  myconfig.always = { myconfig, ... }: {
    editors.vscode.enable = lib.mkDefault (myconfig.editors.enable or false);
  };

  home.ifEnabled =
    let
      marketplace = pkgs.vscode-marketplace;
      package =
        if pkgs.stdenv.isDarwin then pkgs.vscodium
        else pkgs.symlinkJoin {
          name = "${pkgs.vscodium.name}-wayland";
          pname = pkgs.vscodium.pname;
          version = pkgs.vscodium.version;
          meta = pkgs.vscodium.meta;
          paths = [ pkgs.vscodium ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/codium \
              --set ELECTRON_OZONE_PLATFORM_HINT auto \
              --set NIXOS_OZONE_WL 1
          '';
        };

      general = {
        "vim.easymotion" = true;
        "vim.useSystemClipboard" = true;
        "vscode-pets.throwBallWithMouse" = true;
        "chat.disableAIFeatures" = false;
        "vim.normalModeKeyBindingsNonRecursive" = [
          {
            "before" = [ "<space>" ];
            "commands" = [ "vspacecode.space" ];
          }
          {
            "before" = [ "," ];
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
            "before" = [ "<space>" ];
            "commands" = [ "vspacecode.space" ];
          }
          {
            "before" = [ "," ];
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
      programs.vscode = {
        package = package;
        enable = true;
        mutableExtensionsDir = true;
        profiles.default = {
          enableExtensionUpdateCheck = true;
          enableUpdateCheck = false;
          extensions =
            (with pkgs.vscode-extensions; [
              aaron-bond.better-comments
              brettm12345.nixfmt-vscode
              github.copilot
              github.copilot-chat
              jebbs.plantuml
              jnoortheen.nix-ide
              mechatroner.rainbow-csv
              mkhl.direnv
              ms-toolsai.jupyter
              ms-toolsai.jupyter-keymap
              ms-toolsai.jupyter-renderers
              ms-toolsai.vscode-jupyter-cell-tags
              ms-toolsai.vscode-jupyter-slideshow
              ms-vscode-remote.remote-ssh
              ms-vscode.live-server
              oderwat.indent-rainbow
              usernamehw.errorlens
              vscodevim.vim
              vspacecode.vspacecode
              vspacecode.whichkey
              yzhang.markdown-all-in-one
              svelte.svelte-vscode
              streetsidesoftware.code-spell-checker
              github.vscode-github-actions
              charliermarsh.ruff
            ])
            ++ (with marketplace; [
              buenon.scratchpads
              bodil.file-browser
              jacobdufault.fuzzy-search
              kahole.magit
              maattdd.gitless
              roipoussiere.cadquery
              tonybaloney.vscode-pets
              bernhard-42.ocp-cad-viewer
              anthropic.claude-code
              marimo-team.vscode-marimo
              openai.chatgpt
              astral-sh.ty
            ]);
          userSettings = general // editor // git // languages;
          keybindings = [
            {
              "key" = "space";
              "command" = "vspacecode.space";
              "when" = "activeEditorGroupEmpty && focusedView == '' && !whichkeyActive && !inputFocus";
            }
            {
              "key" = "space";
              "command" = "vspacecode.space";
              "when" = "sideBarFocus && !inputFocus && !whichkeyActive";
            }
            {
              "key" = "tab";
              "command" = "extension.vim_tab";
              "when" =
                "editorFocus && vim.active && !inDebugRepl && vim.mode != 'Insert' && editorLangId != 'magit'";
            }
            {
              "key" = "tab";
              "command" = "-extension.vim_tab";
              "when" = "editorFocus && vim.active && !inDebugRepl && vim.mode != 'Insert'";
            }
            {
              "key" = "x";
              "command" = "magit.discard-at-point";
              "when" =
                "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
            }
            {
              "key" = "k";
              "command" = "-magit.discard-at-point";
            }
            {
              "key" = "-";
              "command" = "magit.reverse-at-point";
              "when" =
                "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
            }
            {
              "key" = "v";
              "command" = "-magit.reverse-at-point";
            }
            {
              "key" = "shift+-";
              "command" = "magit.reverting";
              "when" =
                "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
            }
            {
              "key" = "shift+v";
              "command" = "-magit.reverting";
            }
            {
              "key" = "shift+o";
              "command" = "magit.resetting";
              "when" =
                "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
            }
            {
              "key" = "shift+x";
              "command" = "-magit.resetting";
            }
            {
              "key" = "x";
              "command" = "-magit.reset-mixed";
            }
            {
              "key" = "ctrl+u x";
              "command" = "-magit.reset-hard";
            }
            {
              "key" = "y";
              "command" = "-magit.show-refs";
            }
            {
              "key" = "y";
              "command" = "vspacecode.showMagitRefMenu";
              "when" = "editorTextFocus && editorLangId == 'magit' && vim.mode == 'Normal'";
            }
            {
              "key" = "ctrl+j";
              "command" = "workbench.action.quickOpenSelectNext";
              "when" = "inQuickOpen";
            }
            {
              "key" = "ctrl+k";
              "command" = "workbench.action.quickOpenSelectPrevious";
              "when" = "inQuickOpen";
            }
            {
              "key" = "ctrl+j";
              "command" = "selectNextSuggestion";
              "when" = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus";
            }
            {
              "key" = "ctrl+k";
              "command" = "selectPrevSuggestion";
              "when" = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus";
            }
            {
              "key" = "ctrl+l";
              "command" = "acceptSelectedSuggestion";
              "when" = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus";
            }
            {
              "key" = "ctrl+j";
              "command" = "showNextParameterHint";
              "when" = "editorFocus && parameterHintsMultipleSignatures && parameterHintsVisible";
            }
            {
              "key" = "ctrl+k";
              "command" = "showPrevParameterHint";
              "when" = "editorFocus && parameterHintsMultipleSignatures && parameterHintsVisible";
            }
            {
              "key" = "ctrl+j";
              "command" = "selectNextCodeAction";
              "when" = "codeActionMenuVisible";
            }
            {
              "key" = "ctrl+k";
              "command" = "selectPrevCodeAction";
              "when" = "codeActionMenuVisible";
            }
            {
              "key" = "ctrl+l";
              "command" = "acceptSelectedSuggestion";
              "when" = "codeActionMenuVisible";
            }
            {
              "key" = "ctrl+h";
              "command" = "file-browser.stepOut";
              "when" = "inFileBrowser";
            }
            {
              "key" = "ctrl+l";
              "command" = "file-browser.stepIn";
              "when" = "inFileBrowser";
            }
            {
              "key" = "ctrl+shift+j";
              "command" = "workbench.action.quickOpen";
            }
          ];
        };
      };
    };
}

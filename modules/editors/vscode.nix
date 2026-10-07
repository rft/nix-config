{
  delib,
  lib,
  pkgs,
  ...
}:
let
  t = import ../../lib/titanium-palette.nix;
in
delib.module {
  name = "editors.vscode";

  options = delib.singleEnableOption true;

  myconfig.always =
    { myconfig, ... }:
    {
      editors.vscode.enable = lib.mkDefault (myconfig.editors.enable or false);
    };

  home.ifEnabled =
    let
      marketplace = pkgs.vscode-marketplace;
      openVsx = pkgs.open-vsx;
      package =
        if pkgs.stdenv.hostPlatform.isDarwin then
          pkgs.vscodium
        else
          pkgs.symlinkJoin {
            name = "${pkgs.vscodium.name}-wayland";
            inherit (pkgs.vscodium) pname version meta;
            paths = [ pkgs.vscodium ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            # Auto-updated ruff/ty extensions ship generic-linux binaries that
            # NixOS cannot run. Both look on PATH before their bundled copy, so
            # offer the nixpkgs builds as a fallback; a devenv's own wins.
            postBuild = ''
              wrapProgram $out/bin/codium \
                --set ELECTRON_OZONE_PLATFORM_HINT auto \
                --set NIXOS_OZONE_WL 1 \
                --suffix PATH : ${
                  lib.makeBinPath [
                    pkgs.ruff
                    pkgs.ty
                  ]
                }
            '';
          };

      commandBinding = keys: name: command: {
        inherit keys name command;
        type = "command";
      };

      # WhichKey's when conditions are tags supplied by triggerKey, not
      # expressions it evaluates. The matching relays live in keybindings.
      selectionBinding = keys: name: command: selectedCommand: {
        inherit keys name;
        type = "conditional";
        bindings = [
          { key = ""; type = "command"; inherit name command; }
          {
            key = "when:selection";
            type = "command";
            inherit name;
            command = selectedCommand;
          }
        ];
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
        ];
        "vspacecode.bindingOverrides" = [
          (commandBinding "f.f" "Find project file" "workbench.action.quickOpen")
          (commandBinding "f.o" "Browse filesystem" "file-browser.open")
          (commandBinding "f.O" "Open with" "explorer.openWith")
          (commandBinding "f.r" "Recent files and workspaces" "workbench.action.openRecent")
          (commandBinding "b.N" "New buffer" "workbench.action.files.newUntitledFile")
          (commandBinding "b.P" "Close unpinned buffers" "workbench.action.closeAllEditors")
          {
            keys = "b.y";
            name = "Paste clipboard into new buffer";
            type = "commands";
            commands = [
              "workbench.action.files.newUntitledFile"
              "editor.action.clipboardPasteAction"
            ];
          }
          {
            keys = "b.t";
            name = "Toggle buffer pin";
            type = "conditional";
            bindings = [
              { key = ""; name = "Pin buffer"; type = "command"; command = "workbench.action.pinEditor"; }
              { key = "when:pinned"; name = "Unpin buffer"; type = "command"; command = "workbench.action.unpinEditor"; }
              { key = "when:pinned-tree"; name = "Unpin buffer"; type = "command"; command = "workbench.action.unpinEditor"; }
            ];
          }
          # Preserve the explorer toggle when the pin relay supplies both tags.
          {
            keys = [ "f" "t" "when:pinned-tree" ];
            name = "Hide side bar";
            type = "command";
            command = "workbench.action.toggleSidebarVisibility";
          }
          (commandBinding "c.d" "Go to definition" "editor.action.revealDefinition")
          (commandBinding "c.r" "Find references" "editor.action.referenceSearch.trigger")
          (commandBinding "c.R" "Rename symbol" "editor.action.rename")
          (commandBinding "c.k" "Hover documentation" "editor.action.showHover")
          (commandBinding "c.t" "Go to type definition" "editor.action.goToTypeDefinition")
          (selectionBinding "c.f" "Format buffer or selection" "editor.action.formatDocument" "editor.action.formatSelection")
          { keys = "c.l"; position = -1; }
          { keys = "s.r"; position = -1; }
          (commandBinding "s.R" "Replace in project" "workbench.action.replaceInFiles")
          (commandBinding "s.a" "References in side bar" "references-view.find")
          (commandBinding "s.C" "Toggle search case sensitivity" "toggleFindCaseSensitive")
          { keys = "t.c"; position = -1; }
          (commandBinding ";" "Toggle comment" "editor.action.commentLine")
          (commandBinding "g.g" "Git status" "magit.status")
          (selectionBinding "g.s" "Stage hunk or selection" "git.diff.stageHunk" "git.stageSelectedRanges")
          (commandBinding "g.S" "Stage file" "git.stage")
          (commandBinding "w.c" "Close split" "workbench.action.closeEditorsInGroup")
          (commandBinding "w.o" "Keep only current split" "workbench.action.joinAllGroups")
          (commandBinding "w.f" "Switch application window" "workbench.action.quickSwitchWindow")
          { keys = "w.d"; position = -1; }
          {
            keys = "o";
            name = "+Open";
            type = "bindings";
            bindings = [
              { key = "t"; name = "Terminal"; type = "command"; command = "workbench.action.terminal.toggleTerminal"; }
            ];
          }
        ];
        "vim.visualModeKeyBindingsNonRecursive" = [
          {
            "before" = [ "<space>" ];
            "commands" = [ "vspacecode.space" ];
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

      # Titanium palette layered over the built-in dark theme, so the editor
      # matches nvim, zellij, rofi and the rest without a theme extension.
      theme = {
        "workbench.colorTheme" = "Dark Modern";
        "workbench.colorCustomizations" = {
          "focusBorder" = t.electricBlue;
          "foreground" = t.brightAluminum;
          "descriptionForeground" = t.dimAluminum;
          "errorForeground" = t.alertRed;
          "widget.border" = t.subtleGray;
          "selection.background" = t.subtleGray;
          "textLink.foreground" = t.electricBlue;
          "textLink.activeForeground" = t.electricBlue;

          "button.background" = t.deepBlue;
          "button.foreground" = t.brightAluminum;
          "button.hoverBackground" = t.electricBlue;
          "badge.background" = t.electricBlue;
          "badge.foreground" = t.darkTitanium;
          "progressBar.background" = t.electricBlue;

          "input.background" = t.borderMuted;
          "input.border" = t.subtleGray;
          "input.foreground" = t.brightAluminum;
          "input.placeholderForeground" = t.comment;
          "dropdown.background" = t.darkTitanium;
          "dropdown.border" = t.subtleGray;

          "titleBar.activeBackground" = t.darkTitanium;
          "titleBar.activeForeground" = t.brightAluminum;
          "titleBar.inactiveBackground" = t.darkTitanium;
          "titleBar.inactiveForeground" = t.comment;
          "titleBar.border" = t.subtleGray;
          "menu.background" = t.darkTitanium;
          "menu.foreground" = t.brightAluminum;
          "menu.selectionBackground" = t.subtleGray;
          "menu.border" = t.subtleGray;

          "activityBar.background" = t.darkTitanium;
          "activityBar.foreground" = t.brightAluminum;
          "activityBar.inactiveForeground" = t.comment;
          "activityBar.activeBorder" = t.electricBlue;
          "activityBar.border" = t.subtleGray;
          "activityBarBadge.background" = t.electricBlue;
          "activityBarBadge.foreground" = t.darkTitanium;

          "sideBar.background" = t.darkTitanium;
          "sideBar.foreground" = t.dimAluminum;
          "sideBar.border" = t.subtleGray;
          "sideBarTitle.foreground" = t.brightAluminum;
          "sideBarSectionHeader.background" = t.darkTitanium;
          "sideBarSectionHeader.foreground" = t.titaniumGold;
          "sideBarSectionHeader.border" = t.subtleGray;

          "list.activeSelectionBackground" = t.subtleGray;
          "list.activeSelectionForeground" = t.brightAluminum;
          "list.inactiveSelectionBackground" = t.borderMuted;
          "list.hoverBackground" = t.borderMuted;
          "list.focusOutline" = t.electricBlue;
          "list.highlightForeground" = t.electricBlue;

          "editorGroupHeader.tabsBackground" = t.darkTitanium;
          "editorGroupHeader.tabsBorder" = t.subtleGray;
          "editorGroup.border" = t.subtleGray;
          "tab.activeBackground" = t.brushedTitanium;
          "tab.activeForeground" = t.brightAluminum;
          "tab.activeBorderTop" = t.electricBlue;
          "tab.inactiveBackground" = t.darkTitanium;
          "tab.inactiveForeground" = t.comment;
          "tab.border" = t.subtleGray;
          "breadcrumb.foreground" = t.dimAluminum;
          "breadcrumb.background" = t.brushedTitanium;

          "editor.background" = t.brushedTitanium;
          "editor.foreground" = t.brightAluminum;
          "editor.lineHighlightBackground" = t.borderMuted;
          "editor.lineHighlightBorder" = t.borderMuted;
          "editor.selectionBackground" = t.subtleGray;
          "editor.inactiveSelectionBackground" = t.borderMuted;
          "editor.findMatchBackground" = "${t.warningAmber}55";
          "editor.findMatchHighlightBackground" = "${t.warningAmber}30";
          "editor.wordHighlightBackground" = t.slate;
          "editorCursor.foreground" = t.electricBlue;
          "editorLineNumber.foreground" = t.comment;
          "editorLineNumber.activeForeground" = t.titaniumGold;
          "editorIndentGuide.background1" = t.borderMuted;
          "editorIndentGuide.activeBackground1" = t.subtleGray;
          "editorWhitespace.foreground" = t.subtleGray;
          "editorBracketMatch.border" = t.electricBlue;
          "editorBracketMatch.background" = t.subtleGray;
          "editorWidget.background" = t.darkTitanium;
          "editorWidget.border" = t.subtleGray;
          "editorSuggestWidget.background" = t.darkTitanium;
          "editorSuggestWidget.border" = t.subtleGray;
          "editorSuggestWidget.selectedBackground" = t.subtleGray;
          "editorSuggestWidget.highlightForeground" = t.electricBlue;
          "editorHoverWidget.background" = t.darkTitanium;
          "editorHoverWidget.border" = t.subtleGray;
          "editorError.foreground" = t.alertRed;
          "editorWarning.foreground" = t.warningAmber;
          "editorInfo.foreground" = t.electricBlue;
          "editorGutter.addedBackground" = t.readoutGreen;
          "editorGutter.modifiedBackground" = t.electricBlue;
          "editorGutter.deletedBackground" = t.alertRed;

          "panel.background" = t.darkTitanium;
          "panel.border" = t.subtleGray;
          "panelTitle.activeForeground" = t.brightAluminum;
          "panelTitle.activeBorder" = t.electricBlue;
          "panelTitle.inactiveForeground" = t.comment;

          "statusBar.background" = t.darkTitanium;
          "statusBar.foreground" = t.dimAluminum;
          "statusBar.border" = t.subtleGray;
          "statusBar.debuggingBackground" = t.warningAmber;
          "statusBar.debuggingForeground" = t.darkTitanium;
          "statusBar.noFolderBackground" = t.darkTitanium;
          "statusBarItem.remoteBackground" = t.deepBlue;
          "statusBarItem.remoteForeground" = t.brightAluminum;

          "quickInput.background" = t.darkTitanium;
          "quickInputList.focusBackground" = t.subtleGray;
          "notifications.background" = t.darkTitanium;
          "notifications.border" = t.subtleGray;
          "scrollbarSlider.background" = "${t.subtleGray}80";
          "scrollbarSlider.hoverBackground" = t.subtleGray;
          "scrollbarSlider.activeBackground" = t.slate;

          "gitDecoration.addedResourceForeground" = t.readoutGreen;
          "gitDecoration.untrackedResourceForeground" = t.readoutGreen;
          "gitDecoration.modifiedResourceForeground" = t.electricBlue;
          "gitDecoration.deletedResourceForeground" = t.alertRed;
          "gitDecoration.conflictingResourceForeground" = t.warningAmber;
          "gitDecoration.ignoredResourceForeground" = t.comment;

          "terminal.background" = t.brushedTitanium;
          "terminal.foreground" = t.brightAluminum;
          "terminalCursor.foreground" = t.electricBlue;
          "terminal.ansiBlack" = t.subtleGray;
          "terminal.ansiRed" = t.alertRed;
          "terminal.ansiGreen" = t.readoutGreen;
          "terminal.ansiYellow" = t.warningAmber;
          "terminal.ansiBlue" = t.deepBlue;
          "terminal.ansiMagenta" = t.titaniumGold;
          "terminal.ansiCyan" = t.electricBlue;
          "terminal.ansiWhite" = t.dimAluminum;
          "terminal.ansiBrightBlack" = t.comment;
          "terminal.ansiBrightRed" = t.alertRed;
          "terminal.ansiBrightGreen" = t.readoutGreen;
          "terminal.ansiBrightYellow" = t.warningAmber;
          "terminal.ansiBrightBlue" = t.electricBlue;
          "terminal.ansiBrightMagenta" = t.titaniumGold;
          "terminal.ansiBrightCyan" = t.electricBlue;
          "terminal.ansiBrightWhite" = t.brightAluminum;
        };
        "editor.tokenColorCustomizations" = {
          "textMateRules" =
            let
              rule = scope: foreground: extra: {
                inherit scope;
                settings = {
                  inherit foreground;
                }
                // extra;
              };
            in
            [
              (rule [ "comment" "punctuation.definition.comment" ] t.comment { fontStyle = "italic"; })
              (rule [ "keyword" "storage" "storage.type" "keyword.control" ] t.electricBlue { })
              (rule [ "keyword.operator" "punctuation" ] t.dimAluminum { })
              (rule [ "string" "string.quoted" "string.template" ] t.readoutGreen { })
              (rule [ "constant.character.escape" "string.regexp" ] t.warningAmber { })
              (rule [ "constant.numeric" "constant.language" "constant.other" ] t.warningAmber { })
              (rule [ "entity.name.function" "support.function" "meta.function-call" ] t.titaniumGold { })
              (rule [
                "entity.name.type"
                "entity.name.class"
                "support.type"
                "support.class"
                "entity.other.inherited-class"
              ] t.deepBlue { })
              (rule [ "variable" "variable.other" "meta.definition.variable" ] t.brightAluminum { })
              (rule [ "variable.parameter" ] t.dimAluminum { fontStyle = "italic"; })
              (rule [ "variable.language" "support.variable" ] t.electricBlue { fontStyle = "italic"; })
              (rule [ "entity.name.tag" ] t.electricBlue { })
              (rule [ "entity.other.attribute-name" ] t.titaniumGold { })
              (rule [ "invalid" ] t.alertRed { })
              (rule [ "markup.heading" ] t.electricBlue { fontStyle = "bold"; })
              (rule [ "markup.bold" ] t.titaniumGold { fontStyle = "bold"; })
              (rule [ "markup.italic" ] t.brightAluminum { fontStyle = "italic"; })
              (rule [ "markup.inline.raw" "markup.fenced_code" ] t.readoutGreen { })
              (rule [ "markup.underline.link" ] t.electricBlue { })
              (rule [ "markup.inserted" ] t.readoutGreen { })
              (rule [ "markup.deleted" ] t.alertRed { })
              (rule [ "markup.changed" ] t.warningAmber { })
            ];
        };
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
      # home-manager 26.05 made programs.vscode always write to Visual Studio
      # Code's own paths (~/.vscode, "Code/User"), so a vscodium package set
      # there would have its config written where vscodium never reads it.
      # programs.vscodium takes the same schema and targets vscodium's paths.
      programs.vscodium = {
        inherit package;
        enable = true;
        mutableExtensionsDir = true;
        profiles.default = {
          enableExtensionUpdateCheck = true;
          enableUpdateCheck = false;
          extensions =
            (with pkgs.vscode-extensions; [
              aaron-bond.better-comments
              brettm12345.nixfmt-vscode
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
              rust-lang.rust-analyzer
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
              alexkrechik.cucumberautocomplete
              anthropic.claude-code
              marimo-team.vscode-marimo
              openai.chatgpt
              astral-sh.ty
              leanprover.lean4
              foam.foam-vscode
            ])
            # bernhard-42.ocp-cad-viewer hard-depends on ms-python.python and
            # will not activate without it. Open VSX carries the openly
            # licensed build, which is the one vscodium may use.
            ++ (with openVsx; [
              ms-python.python
            ]);
          userSettings = general // editor // theme // git // languages;
          keybindings = [
            {
              key = "f";
              command = "whichkey.triggerKey";
              args = { key = "f"; when = "selection"; };
              when = "whichkeyVisible && vim.mode =~ /^Visual/";
            }
            {
              key = "s";
              command = "whichkey.triggerKey";
              args = { key = "s"; when = "selection"; };
              when = "whichkeyVisible && vim.mode =~ /^Visual/";
            }
            {
              key = "t";
              command = "whichkey.triggerKey";
              args = { key = "t"; when = "pinned"; };
              when = "whichkeyVisible && activeEditorIsPinned && !(sideBarVisible && explorerViewletVisible)";
            }
            {
              key = "t";
              command = "whichkey.triggerKey";
              args = { key = "t"; when = "pinned-tree"; };
              when = "whichkeyVisible && activeEditorIsPinned && sideBarVisible && explorerViewletVisible";
            }
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

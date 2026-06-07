{ delib, pkgs, ... }:
let
  # Mirrored from a live-captured ~/.config/omniwm/settings.toml.
  # The file becomes a read-only symlink into the nix store, so
  # OmniWM's in-app Settings panel will not be able to persist
  # changes — edit this attrset and rebuild instead.
  settings = {
    monitorBarOverrides = [ ];
    monitorDwindleOverrides = [ ];
    monitorNiriOverrides = [ ];
    monitorOrientationOverrides = [ ];

    appearance.mode = "dark";

    borders = {
      enabled = true;
      width = 5.0;
      color = {
        alpha = 1.0;
        blue = 0.979300037944676;
        green = 1.0;
        red = 0.08458520228437894;
      };
    };

    clipboard = {
      historyEnabled = false;
      maxItemBytes = 8388608;
      maxItems = 200;
      maxTotalBytes = 67108864;
    };

    dwindle = {
      defaultSplitRatio = 1.0;
      moveToRootStable = true;
      singleWindowAspectRatio = "4:3";
      smartSplit = false;
      splitWidthMultiplier = 1.0;
      useGlobalGaps = true;
    };

    focus = {
      followsMouse = false;
      followsWindowToMonitor = false;
      moveMouseToFocusedWindow = false;
    };

    gaps = {
      size = 16.0;
      outer = {
        bottom = 0.0;
        left = 0.0;
        right = 0.0;
        top = 0.0;
      };
    };

    general = {
      animationsEnabled = true;
      defaultLayoutType = "niri";
      hotkeysEnabled = true;
      hyperTrigger = "Option";
      ipcEnabled = false;
      leaderKey = "Hyper+Space";
      preventSleepEnabled = false;
      sequenceTimeoutMilliseconds = 800;
      updateChecksEnabled = true;
    };

    gestures = {
      fingerCount = 3;
      invertDirection = true;
      mouseResizeModifierKey = "option";
      scrollEnabled = true;
      scrollModifierKey = "optionShift";
      scrollSensitivity = 5.0;
    };

    mouseWarp = {
      axis = "horizontal";
      margin = 1;
      monitorOrder = [ ];
    };

    niri = {
      alwaysCenterSingleColumn = false;
      centerFocusedColumn = "never";
      columnWidthPresets = [ 0.3333333333333333 0.5 0.6666666666666666 ];
      defaultColumnWidth = 0.5;
      infiniteLoop = false;
      maxVisibleColumns = 1;
      singleWindowAspectRatio = "none";
    };

    quakeTerminal = {
      animationDuration = 0.2;
      autoHide = false;
      enabled = true;
      heightPercent = 50.0;
      monitorMode = "focusedWindow";
      opacity = 1.0;
      position = "center";
      widthPercent = 50.0;
    };

    statusBar = {
      showAppNames = false;
      showWorkspaceName = false;
      useWorkspaceId = false;
    };

    workspaceBar = {
      backgroundOpacity = 0.1;
      deduplicateAppIcons = false;
      enabled = true;
      height = 24.0;
      hideEmptyWorkspaces = false;
      labelFontSize = 12.0;
      notchAware = true;
      position = "overlappingMenuBar";
      reserveLayoutSpace = false;
      showFloatingWindows = false;
      showLabels = true;
      windowLevel = "popup";
      xOffset = 0.0;
      yOffset = 0.0;
    };

    appRules = [
      { bundleId = "com.openai.codex";       id = "6A31F08A-4051-4354-B439-42F4C71894A3"; minHeight = 600.0; minWidth = 800.0; }
      { bundleId = "com.eltima.cmd1.pro.mas"; id = "4BA546DA-2875-4BEF-B13F-1539E833B1A0"; minHeight = 550.0; minWidth = 950.0; }
      { bundleId = "com.google.Chrome";      id = "486CEFA6-69AA-4A3C-AF27-BCD38F4F138B"; minHeight = 375.0; minWidth = 500.0; }
      { bundleId = "dev.zed.Zed";            id = "979F05F4-FFA2-4EDD-B23F-08A9944C759F"; minHeight = 240.0; minWidth = 360.0; }
      { bundleId = "com.apple.Safari";       id = "81426D13-C1A5-475E-AFBC-00BBA05042D0"; minHeight = 220.0; minWidth = 574.0; }
      { bundleId = "app.zen-browser.zen";    id = "1CF39647-F30D-4E76-9686-79B551F1B094"; minHeight = 495.0; minWidth = 500.0; }
      { bundleId = "org.mozilla.firefox";    id = "005C00D3-F665-47F8-BDAE-D80790E9E46B"; minHeight = 120.0; minWidth = 500.0; }
      { bundleId = "company.thebrowser.dia"; id = "C21156B1-0224-4998-97E3-8F4FA65B9F3B"; minHeight = 420.0; minWidth = 500.0; }
      { bundleId = "com.spotify.client";     id = "2DE9390B-0DB4-4D0C-9ABA-06F76F1D4EA9"; minHeight = 600.0; minWidth = 800.0; }
      { bundleId = "com.hnc.Discord";        id = "AF752D95-8497-4844-BE20-4C93E73BAEF2"; minHeight = 500.0; minWidth = 800.0; }
      { bundleId = "com.mitchellh.ghostty";  id = "7876C9EF-437E-4D4F-9C27-B1B02F4AABCE"; minHeight = 48.0;  minWidth = 90.0; }
      { bundleId = "com.microsoft.Outlook";  id = "8ECAB78B-BCDD-4245-BC25-1609A49B1C86"; minHeight = 650.0; minWidth = 930.0; }
      { bundleId = "com.apple.MobileSMS";    id = "552FB77D-BF0E-4737-90A6-B5BC6986C579"; minHeight = 320.0; minWidth = 660.0; }
    ];

    hotkeys = [
      { id = "switchWorkspace.0";                    binding = "Hyper+1"; }
      { id = "moveToWorkspace.0";                    binding = "Hyper+Shift+1"; }
      { id = "switchWorkspace.1";                    binding = "Hyper+2"; }
      { id = "moveToWorkspace.1";                    binding = "Hyper+Shift+2"; }
      { id = "switchWorkspace.2";                    binding = "Hyper+3"; }
      { id = "moveToWorkspace.2";                    binding = "Hyper+Shift+3"; }
      { id = "switchWorkspace.3";                    binding = "Hyper+4"; }
      { id = "moveToWorkspace.3";                    binding = "Hyper+Shift+4"; }
      { id = "switchWorkspace.4";                    binding = "Hyper+5"; }
      { id = "moveToWorkspace.4";                    binding = "Hyper+Shift+5"; }
      { id = "switchWorkspace.5";                    binding = "Hyper+6"; }
      { id = "moveToWorkspace.5";                    binding = "Hyper+Shift+6"; }
      { id = "switchWorkspace.6";                    binding = "Hyper+7"; }
      { id = "moveToWorkspace.6";                    binding = "Hyper+Shift+7"; }
      { id = "switchWorkspace.7";                    binding = "Hyper+8"; }
      { id = "moveToWorkspace.7";                    binding = "Hyper+Shift+8"; }
      { id = "switchWorkspace.8";                    binding = "Hyper+9"; }
      { id = "moveToWorkspace.8";                    binding = "Hyper+Shift+9"; }
      { id = "workspaceBackAndForth";                binding = "Hyper+Control+Tab"; }
      { id = "switchWorkspace.next";                 binding = "Unassigned"; }
      { id = "switchWorkspace.previous";             binding = "Unassigned"; }
      { id = "focus.left";                           binding = "Hyper+H"; }
      { id = "focus.down";                           binding = "Hyper+J"; }
      { id = "focus.up";                             binding = "Hyper+K"; }
      { id = "focus.right";                          binding = "Hyper+L"; }
      { id = "focusPrevious";                        binding = "Hyper+Tab"; }
      { id = "focusDownOrLeft";                      binding = "Unassigned"; }
      { id = "focusUpOrRight";                       binding = "Unassigned"; }
      { id = "focusWindowTop";                       binding = "Unassigned"; }
      { id = "focusWindowBottom";                    binding = "Unassigned"; }
      { id = "focusWindowDownOrTop";                 binding = "Unassigned"; }
      { id = "focusWindowUpOrBottom";                binding = "Unassigned"; }
      { id = "focusWindowOrWorkspaceDown";           binding = "Unassigned"; }
      { id = "focusWindowOrWorkspaceUp";             binding = "Unassigned"; }
      { id = "centerColumn";                         binding = "Unassigned"; }
      { id = "centerVisibleColumns";                 binding = "Unassigned"; }
      { id = "moveWindowToWorkspaceUp";              binding = "Hyper+Control+Shift+Up Arrow"; }
      { id = "moveWindowToWorkspaceDown";            binding = "Hyper+Control+Shift+Down Arrow"; }
      { id = "moveColumnToWorkspaceUp";              binding = "Hyper+Control+Shift+Page Up"; }
      { id = "moveColumnToWorkspaceDown";            binding = "Hyper+Control+Shift+Page Down"; }
      { id = "moveColumnToWorkspace.0";              binding = "Unassigned"; }
      { id = "moveColumnToWorkspace.1";              binding = "Unassigned"; }
      { id = "moveColumnToWorkspace.2";              binding = "Unassigned"; }
      { id = "moveColumnToWorkspace.3";              binding = "Unassigned"; }
      { id = "moveColumnToWorkspace.4";              binding = "Unassigned"; }
      { id = "moveColumnToWorkspace.5";              binding = "Unassigned"; }
      { id = "moveColumnToWorkspace.6";              binding = "Unassigned"; }
      { id = "moveColumnToWorkspace.7";              binding = "Unassigned"; }
      { id = "moveColumnToWorkspace.8";              binding = "Unassigned"; }
      { id = "move.left";                            binding = "Hyper+Shift+H"; }
      { id = "move.down";                            binding = "Hyper+Shift+J"; }
      { id = "move.up";                              binding = "Hyper+Shift+K"; }
      { id = "move.right";                           binding = "Hyper+Shift+L"; }
      { id = "moveWindowDown";                       binding = "Unassigned"; }
      { id = "moveWindowUp";                         binding = "Unassigned"; }
      { id = "moveWindowDownOrToWorkspaceDown";      binding = "Unassigned"; }
      { id = "moveWindowUpOrToWorkspaceUp";          binding = "Unassigned"; }
      { id = "consumeOrExpelWindowLeft";             binding = "Unassigned"; }
      { id = "consumeOrExpelWindowRight";            binding = "Unassigned"; }
      { id = "consumeWindowIntoColumn";              binding = "Unassigned"; }
      { id = "expelWindowFromColumn";                binding = "Unassigned"; }
      { id = "focusMonitorNext";                     binding = "Control+Command+Tab"; }
      { id = "focusMonitorPrevious";                 binding = "Unassigned"; }
      { id = "focusMonitorLast";                     binding = "Control+Command+Grave"; }
      { id = "toggleFullscreen";                     binding = "Hyper+Return"; }
      { id = "toggleNativeFullscreen";               binding = "Unassigned"; }
      { id = "moveColumn.left";                      binding = "Hyper+Control+Shift+Left Arrow"; }
      { id = "moveColumn.right";                     binding = "Hyper+Control+Shift+Right Arrow"; }
      { id = "moveColumnToFirst";                    binding = "Hyper+Control+Home"; }
      { id = "moveColumnToLast";                     binding = "Hyper+Control+End"; }
      { id = "toggleColumnTabbed";                   binding = "Hyper+T"; }
      { id = "focusColumnFirst";                     binding = "Hyper+Home"; }
      { id = "focusColumnLast";                      binding = "Hyper+End"; }
      { id = "focusColumn.0";                        binding = "Hyper+Control+1"; }
      { id = "focusColumn.1";                        binding = "Hyper+Control+2"; }
      { id = "focusColumn.2";                        binding = "Hyper+Control+3"; }
      { id = "focusColumn.3";                        binding = "Hyper+Control+4"; }
      { id = "focusColumn.4";                        binding = "Hyper+Control+5"; }
      { id = "focusColumn.5";                        binding = "Hyper+Control+6"; }
      { id = "focusColumn.6";                        binding = "Hyper+Control+7"; }
      { id = "focusColumn.7";                        binding = "Hyper+Control+8"; }
      { id = "focusColumn.8";                        binding = "Hyper+Control+9"; }
      { id = "focusWindowInColumn.1";                binding = "Unassigned"; }
      { id = "focusWindowInColumn.2";                binding = "Unassigned"; }
      { id = "focusWindowInColumn.3";                binding = "Unassigned"; }
      { id = "focusWindowInColumn.4";                binding = "Unassigned"; }
      { id = "focusWindowInColumn.5";                binding = "Unassigned"; }
      { id = "focusWindowInColumn.6";                binding = "Unassigned"; }
      { id = "focusWindowInColumn.7";                binding = "Unassigned"; }
      { id = "focusWindowInColumn.8";                binding = "Unassigned"; }
      { id = "focusWindowInColumn.9";                binding = "Unassigned"; }
      { id = "moveColumnToIndex.1";                  binding = "Unassigned"; }
      { id = "moveColumnToIndex.2";                  binding = "Unassigned"; }
      { id = "moveColumnToIndex.3";                  binding = "Unassigned"; }
      { id = "moveColumnToIndex.4";                  binding = "Unassigned"; }
      { id = "moveColumnToIndex.5";                  binding = "Unassigned"; }
      { id = "moveColumnToIndex.6";                  binding = "Unassigned"; }
      { id = "moveColumnToIndex.7";                  binding = "Unassigned"; }
      { id = "moveColumnToIndex.8";                  binding = "Unassigned"; }
      { id = "moveColumnToIndex.9";                  binding = "Unassigned"; }
      { id = "cycleColumnWidthForward";              binding = "Hyper+Period"; }
      { id = "cycleColumnWidthBackward";             binding = "Hyper+Comma"; }
      { id = "cycleWindowWidthForward";              binding = "Unassigned"; }
      { id = "cycleWindowWidthBackward";             binding = "Unassigned"; }
      { id = "cycleWindowHeightForward";             binding = "Unassigned"; }
      { id = "cycleWindowHeightBackward";            binding = "Unassigned"; }
      { id = "toggleColumnFullWidth";                binding = "Hyper+Shift+F"; }
      { id = "expandColumnToAvailableWidth";         binding = "Hyper+Control+F"; }
      { id = "resetWindowHeight";                    binding = "Hyper+Control+R"; }
      { id = "setColumnWidth.decrease10Percent";     binding = "Hyper+Minus"; }
      { id = "setColumnWidth.increase10Percent";     binding = "Hyper+Equal"; }
      { id = "setWindowWidth.decrease10Percent";     binding = "Unassigned"; }
      { id = "setWindowWidth.increase10Percent";     binding = "Unassigned"; }
      { id = "setWindowHeight.decrease10Percent";    binding = "Hyper+Shift+Minus"; }
      { id = "setWindowHeight.increase10Percent";    binding = "Hyper+Shift+Equal"; }
      { id = "balanceSizes";                         binding = "Hyper+Shift+B"; }
      { id = "moveToRoot";                           binding = "Unassigned"; }
      { id = "toggleSplit";                          binding = "Unassigned"; }
      { id = "swapSplit";                            binding = "Unassigned"; }
      { id = "resizeGrow.left";                      binding = "Unassigned"; }
      { id = "resizeGrow.right";                     binding = "Unassigned"; }
      { id = "resizeGrow.up";                        binding = "Unassigned"; }
      { id = "resizeGrow.down";                      binding = "Unassigned"; }
      { id = "resizeShrink.left";                    binding = "Unassigned"; }
      { id = "resizeShrink.right";                   binding = "Unassigned"; }
      { id = "resizeShrink.up";                      binding = "Unassigned"; }
      { id = "resizeShrink.down";                    binding = "Unassigned"; }
      { id = "preselect.left";                       binding = "Unassigned"; }
      { id = "preselect.right";                      binding = "Unassigned"; }
      { id = "preselect.up";                         binding = "Unassigned"; }
      { id = "preselect.down";                       binding = "Unassigned"; }
      { id = "preselectClear";                       binding = "Unassigned"; }
      { id = "openCommandPalette";                   binding = "Hyper+Control+Space"; }
      { id = "raiseAllFloatingWindows";              binding = "Hyper+Shift+R"; }
      { id = "rescueOffscreenWindows";               binding = "Unassigned"; }
      { id = "toggleFocusedWindowFloating";          binding = "Unassigned"; }
      { id = "assignFocusedWindowToScratchpad";      binding = "Unassigned"; }
      { id = "toggleScratchpadWindow";               binding = "Unassigned"; }
      { id = "openMenuAnywhere";                     binding = "Hyper+Control+M"; }
      { id = "toggleWorkspaceBarVisibility";         binding = "Unassigned"; }
      { id = "toggleHiddenBar";                      binding = "Unassigned"; }
      { id = "toggleQuakeTerminal";                  binding = "Hyper+Grave"; }
      { id = "toggleWorkspaceLayout";                binding = "Hyper+Shift+L"; }
      { id = "toggleOverview";                       binding = "Hyper+Shift+O"; }
    ];

    workspaces = [
      { id = "AD36F001-C57E-41A5-AC1D-DF5249D007F0"; layoutType = "niri"; name = "1"; monitorAssignment.type = "main"; }
      { id = "454CECD4-5E9D-4ED1-95D7-979D48817F5F"; layoutType = "niri"; name = "2"; monitorAssignment.type = "main"; }
      { id = "BEB842B5-E894-4791-9FD1-397C3CDD3538"; layoutType = "niri"; name = "3"; monitorAssignment.type = "main"; }
      { id = "248AA883-2261-4D45-943C-79C0E46A232B"; layoutType = "niri"; name = "4"; monitorAssignment.type = "main"; }
      { id = "8B8C45D6-CE9E-41D9-BD50-BE4989D5E3DE"; layoutType = "dwindle"; name = "5"; monitorAssignment.type = "main"; }
      { id = "5953F2BF-A378-4266-91B2-287174C4FA4D"; layoutType = "niri"; name = "6"; displayName = "6"; monitorAssignment.type = "secondary"; }
      { id = "A7D5E104-6985-4516-8ED5-07F144F2A33D"; layoutType = "niri"; name = "7"; displayName = "7"; monitorAssignment.type = "secondary"; }
    ];
  };

  tomlFormat = pkgs.formats.toml { };
in
delib.module {
  name = "desktop.omniwm";

  options = delib.singleEnableOption false;

  darwin.ifEnabled = {
    homebrew.taps = [ "BarutSRB/tap" ];
    homebrew.casks = [ "BarutSRB/tap/omniwm" ];
  };

  home.ifEnabled = {
    home.file.".config/omniwm/settings.toml".source =
      tomlFormat.generate "omniwm-settings.toml" settings;
  };
}

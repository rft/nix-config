{ delib, lib, ... }:
let
  t = import ../../lib/titanium-palette.nix;

  # Zellij styles take a base/background pair plus four emphasis colours;
  # 0 means "terminal default". Emphasis order is kept consistent across
  # components: warning, accent, success, gold.
  style = base: background: {
    inherit base background;
    emphasis_0 = t.warningAmber;
    emphasis_1 = t.electricBlue;
    emphasis_2 = t.readoutGreen;
    emphasis_3 = t.titaniumGold;
  };

  titanium = {
    text_unselected = style t.brightAluminum t.brushedTitanium;
    text_selected = style t.brightAluminum t.subtleGray;
    ribbon_selected = style t.darkTitanium t.electricBlue // { emphasis_0 = t.alertRed; emphasis_1 = t.darkTitanium; };
    ribbon_unselected = style t.brightAluminum t.subtleGray;
    table_title = style t.electricBlue 0;
    table_cell_selected = style t.brightAluminum t.subtleGray;
    table_cell_unselected = style t.brightAluminum t.brushedTitanium;
    list_selected = style t.brightAluminum t.subtleGray;
    list_unselected = style t.brightAluminum t.brushedTitanium;
    frame_selected = style t.electricBlue 0;
    frame_unselected = style t.subtleGray 0;
    frame_highlight = style t.warningAmber 0;
    exit_code_success = style t.readoutGreen 0;
    exit_code_error = style t.alertRed 0 // { emphasis_0 = t.warningAmber; };
    multiplayer_user_colors = {
      player_1 = t.electricBlue;
      player_2 = t.readoutGreen;
      player_3 = t.titaniumGold;
      player_4 = t.warningAmber;
      player_5 = t.deepBlue;
      player_6 = t.alertRed;
      player_7 = t.dimAluminum;
      player_8 = 0;
      player_9 = 0;
      player_10 = 0;
    };
  };

  value = v: if builtins.isString v then ''"${v}"'' else toString v;
  block = name: attrs: ''
    ${name} {
    ${lib.concatStrings (lib.mapAttrsToList (k: v: "    ${k} ${value v}\n") attrs)}}
  '';
in
delib.module {
  name = "terminal.zellij";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.zellij.enable = true;
    xdg.configFile."zellij/config.kdl".text = ''
      theme "titanium"

      themes {
      titanium {
      ${lib.concatStrings (lib.mapAttrsToList block titanium)}}
      }
    '';
  };
}

{ delib, pkgs, ... }:
let
  # OmniWM's settings.toml schema is not publicly documented. Run OmniWM
  # once after install, inspect the file it generates at
  # ~/.config/omniwm/settings.toml, then mirror the keys here. README
  # references sections [layout], [hotkeys], [gestures], [mouse],
  # [app_rules], [quake]. The file is live-reloaded when saved.
  settings = { };

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

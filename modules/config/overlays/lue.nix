{ delib, ... }:
delib.overlayModule {
  name = "lue";
  # Default lue to vim keybindings. lue reads its keymap default from
  # CUSTOM_KEYBOARD_SHORTCUTS in config.py (there is no user config file), so
  # patch that value at build time. The `-k` CLI flag still overrides it.
  overlay = _final: prev: {
    lue = prev.lue.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        substituteInPlace $out/${prev.python3.sitePackages}/lue/config.py \
          --replace-fail 'CUSTOM_KEYBOARD_SHORTCUTS = "default"' \
                         'CUSTOM_KEYBOARD_SHORTCUTS = "vim"'
      '';
    });
  };
}

{ delib, lib, pkgs, inputs, ... }:
let
  sharedPackages = with pkgs; [
    ripgrep
    fd
    git
  ];
  emacsPackage = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.emacs30 else pkgs.emacs30-pgtk;
in
delib.module {
  name = "editors";

  options = delib.singleEnableOption true;

  nixos.ifEnabled = {
    environment.systemPackages = [ emacsPackage ] ++ sharedPackages;
  };

  darwin.ifEnabled = {
    environment.systemPackages = [ emacsPackage ] ++ sharedPackages;
  };

  home.ifEnabled = {
    home.file.".config/doom" = {
      source = ../../config/doom;
      recursive = true;
    };

    home.file.".local/bin/doom" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        exec "$HOME/.config/emacs/bin/doom" "$@"
      '';
    };

    home.activation.installDoomEmacs = inputs.home-manager.lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      export PATH="${lib.makeBinPath ([ emacsPackage pkgs.git pkgs.ripgrep pkgs.fd ] ++ [ pkgs.coreutils ])}:$PATH"
      if [ ! -d "$HOME/.config/emacs" ]; then
        run git clone --depth 1 https://github.com/doomemacs/doomemacs \
          "$HOME/.config/emacs"
      fi
      if [ ! -d "$HOME/.config/emacs/.local/straight" ]; then
        DOOMDIR="$HOME/.config/doom" \
          run "$HOME/.config/emacs/bin/doom" install --no-config --force
      fi
    '';
  };
}

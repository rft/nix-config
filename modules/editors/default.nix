{ delib, lib, pkgs, inputs, ... }:
let
  sharedPackages = with pkgs; [
    ripgrep
    fd
    git
  ];
in
delib.module {
  name = "editors";

  options = delib.singleEnableOption true;

  nixos.ifEnabled = {
    environment.systemPackages = with pkgs; [
      emacs30-pgtk
    ] ++ sharedPackages;
  };

  darwin.ifEnabled = {
    environment.systemPackages = with pkgs; [
      emacs30
    ] ++ sharedPackages;
  };

  home.ifEnabled = {
    home.file.".config/doom" = {
      source = ../../config/doom;
      recursive = true;
    };

    home.activation.installDoomEmacs = inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d "$HOME/.config/emacs" ]; then
        run ${pkgs.git}/bin/git clone --depth 1 https://github.com/doomemacs/doomemacs \
          "$HOME/.config/emacs"
      fi
      if [ ! -d "$HOME/.config/emacs/.local/straight" ]; then
        DOOMDIR="$HOME/.config/doom" \
          run "$HOME/.config/emacs/bin/doom" install --no-config --force
      fi
    '';
  };
}

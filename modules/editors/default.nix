{ delib, inputs, ... }:
delib.module {
  name = "editors";

  options = delib.singleEnableOption true;

  home.always.imports = [ inputs.nix-doom-emacs-unstraightened.hmModule ];

  home.ifEnabled = {
    programs.doom-emacs = {
      enable = false;
      doomDir = ../../homes/x86_64-linux/nano/editors/doom.d;
    };
  };
}

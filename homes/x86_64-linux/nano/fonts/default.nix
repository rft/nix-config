{ config, pkgs, inputs, ... }: {

    home.packages = with pkgs; [
      inter
      fira-code
      fira-code-symbols
      jetbrains-mono
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono"]; }) # TODO: when I upgrade to 25.05 make this using the nicer method https://nixos.wiki/wiki/Fonts

    ];


    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["inter"];
        sansSerif = ["inter"];
        monospace = ["fira-code"];
      };
    };
}

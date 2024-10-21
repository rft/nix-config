{ config, pkgs, inputs, ... }: {

    home.packages = with pkgs; [
      inter
      fira-code
      fira-code-symbols
      jetbrains-mono
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono"]; })

    ];

    fonts.fontconfig = {
      defaultFonts = {
        serif = ["inter"];
        sansSerif = ["inter"];
        monospace = ["fira-code"];
      };
    };
}

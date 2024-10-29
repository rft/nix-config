{ inputs, config, pkgs, lib, ... }: {
  home.file = {
    ".config/awesome".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nix-config/config/awesome";
    #"nix-config/config/awesome/modules/bling".source = inputs.bling.outPath;
    #"nix-config/config/awesome/modules/rubato".source = inputs.rubato.outPath;
  };
}

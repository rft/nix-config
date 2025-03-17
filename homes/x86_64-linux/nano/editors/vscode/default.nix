{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  marketplace = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
  marketplace-release = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace-release;
in
{
  imports = [
    ./keybindings.nix
    ./usersettings.nix
  ];
  programs.vscode = {
    package = pkgs.vscodium;
    enable = true;
    enableExtensionUpdateCheck = true;
    enableUpdateCheck = false;
    mutableExtensionsDir = true;
    extensions =
      # https://search.nixos.org/packages?channel=24.11
      (with pkgs.vscode-extensions; [
        ms-python.python
        ms-vscode-remote.remote-ssh
        ms-toolsai.jupyter
        ms-vscode.live-server
        vspacecode.whichkey
        vspacecode.vspacecode
        vscodevim.vim
        usernamehw.errorlens
        yzhang.markdown-all-in-one
        oderwat.indent-rainbow
        mechatroner.rainbow-csv
        gruntfuggly.todo-tree
        jebbs.plantuml
      ])
      # Can be searched here -> https://marketplace.visualstudio.com/items?itemName=jacobdufault.fuzzy-search url shows the name
      ++ (with marketplace; [
        #github.copilot
       # github.copilot-chat
        roipoussiere.cadquery
        maattdd.gitless
        tonybaloney.vscode-pets
        awesomektvn.scratchpad
        jacobdufault.fuzzy-search
        kahole.magit
        bodil.file-browser
      ])
      ++ (with marketplace-release; [
      ]);
  };
}

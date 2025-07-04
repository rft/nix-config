{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  marketplace = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
  marketplace-release =
    inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace-release;
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
      # https://search.nixos.org/packages?channel=25.05
      (with pkgs.vscode-extensions; [
        aaron-bond.better-comments
        brettm12345.nixfmt-vscode
        github.copilot
        github.copilot-chat
        gruntfuggly.todo-tree
        jebbs.plantuml
        jnoortheen.nix-ide
        mechatroner.rainbow-csv
        mkhl.direnv
        ms-python.python
        ms-toolsai.jupyter
        ms-vscode-remote.remote-ssh
        ms-vscode.live-server
        oderwat.indent-rainbow
        usernamehw.errorlens
        vscodevim.vim
        vspacecode.vspacecode
        vspacecode.whichkey
        yzhang.markdown-all-in-one
        #arrterian.nix-env-selector
      ])
      # Can be searched here -> https://marketplace.visualstudio.com/items?itemName=jacobdufault.fuzzy-search url shows the name
      ++ (with marketplace; [
        awesomektvn.scratchpad
        bodil.file-browser
        jacobdufault.fuzzy-search
        kahole.magit
        maattdd.gitless
        roipoussiere.cadquery
        tonybaloney.vscode-pets
      ])
      ++ (with marketplace-release; [
      ]);
  };
}

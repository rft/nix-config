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
        github.copilot
        github.copilot-chat
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
        aaron-bond.better-comments
        brettm12345.nixfmt-vscode
        mkhl.direnv
        jnoortheen.nix-ide
        #arrterian.nix-env-selector
      ])
      # Can be searched here -> https://marketplace.visualstudio.com/items?itemName=jacobdufault.fuzzy-search url shows the name
      ++ (with marketplace; [
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

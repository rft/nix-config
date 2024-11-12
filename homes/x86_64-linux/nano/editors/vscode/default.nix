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
  ];
  programs.vscode = {
    package = pkgs.vscodium;
    enable = true;
    enableExtensionUpdateCheck = true;
    enableUpdateCheck = false;
    mutableExtensionsDir = true;
    extensions =
      (with pkgs.vscode-extensions; [
        ms-python.python
        ms-vscode-remote.remote-ssh
        ms-toolsai.jupyter
        ms-vscode.live-server
        vspacecode.whichkey
        vspacecode.vspacecode
        usernamehw.errorlens
        yzhang.markdown-all-in-one
        oderwat.indent-rainbow
        mechatroner.rainbow-csv
        gruntfuggly.todo-tree
      ])
      ++ (with marketplace; [
        github.copilot
        github.copilot-chat
        roipoussiere.cadquery
        maattdd.gitless
        tonybaloney.vscode-pets
        awesomektvn.scratchpad
      ])
      ++ (with marketplace-release; [
      ]);
  };
}

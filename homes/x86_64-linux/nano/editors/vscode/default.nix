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
  vscodium-wayland = pkgs.symlinkJoin {
    name = "${pkgs.vscodium.name}-wayland";
    pname = pkgs.vscodium.pname;
    version = pkgs.vscodium.version;
    meta = pkgs.vscodium.meta;
    paths = [ pkgs.vscodium ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/codium \
        --set ELECTRON_OZONE_PLATFORM_HINT auto \
        --set NIXOS_OZONE_WL 1
    '';
  };
in
{
  imports = [
    ./keybindings.nix
    ./usersettings.nix
  ];
  config = lib.mkIf config.modules.home.editors.enable {
    programs.vscode = {
    package = vscodium-wayland;
    enable = true;
    mutableExtensionsDir = true;
    profiles.default = {
      enableExtensionUpdateCheck = true;
      enableUpdateCheck = false;
      extensions =
      # https://search.nixos.org/packages?channel=25.05
      (with pkgs.vscode-extensions; [
        aaron-bond.better-comments
        brettm12345.nixfmt-vscode
        github.copilot
        github.copilot-chat
        jebbs.plantuml
        jnoortheen.nix-ide
        mechatroner.rainbow-csv
        mkhl.direnv
        ms-python.python
        ms-python.debugpy
        ms-python.vscode-pylance
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
        svelte.svelte-vscode
      ])
      # Can be searched here -> https://marketplace.visualstudio.com/items?itemName=jacobdufault.fuzzy-search url shows the name
      ++ (with marketplace; [
        buenon.scratchpads
        bodil.file-browser
        jacobdufault.fuzzy-search
        kahole.magit
        maattdd.gitless
        roipoussiere.cadquery
        tonybaloney.vscode-pets
        bernhard-42.ocp-cad-viewer
        anthropic.claude-code
        marimo-team.vscode-marimo
        openai.chatgpt
      ])
      ++ (with marketplace-release; [
      ]);
    };
  };
  };
}

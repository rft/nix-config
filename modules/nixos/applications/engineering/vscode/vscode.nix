{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
  ];

  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with vscode-extensions; [
        ms-python.python
        ms-vscode-remote.remote-ssh
        ms-toolsai.jupyter
        vspacecode.vspacecode
        usernamehw.errorlens

      ];
    })
  ];

}

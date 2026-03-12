{ pkgs, ... }:

{
  languages.javascript = {
    enable = true;
    npm.install.enable = true;
  };

  languages.typescript.enable = true;
}

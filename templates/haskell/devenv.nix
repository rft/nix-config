{ pkgs, ... }:

{
  languages.haskell = {
    enable = true;
    package = pkgs.ghc;
  };

  packages = [
    pkgs.haskell-language-server
  ];
}

{ pkgs, ... }:

{
  packages = [
    pkgs.veryl
    pkgs.verilator
    pkgs.surfer
  ];
}

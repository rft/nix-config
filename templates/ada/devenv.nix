{ pkgs, ... }:

{
  packages = [
    pkgs.gnat
    pkgs.gprbuild
  ];
}

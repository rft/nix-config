{ lib }:
let
  inherit (lib) attrNames filterAttrs genAttrs mapAttrs;

  homesRoot = ../homes;

  isDirectory = type: type == "directory";

  systemEntries =
    if builtins.pathExists homesRoot then
      filterAttrs (_: type: isDirectory type) (builtins.readDir homesRoot)
    else
      { };

  homeModulesFor = system:
    let
      systemPath = homesRoot + "/${system}";
    in
    if builtins.pathExists systemPath then
      mapAttrs (user: _: import (systemPath + "/${user}"))
        (filterAttrs (_: type: isDirectory type) (builtins.readDir systemPath))
    else
      { };
in
{
  root = homesRoot;
  systems = attrNames systemEntries;
  forSystem = system: homeModulesFor system;
  all = genAttrs (attrNames systemEntries) homeModulesFor;
}

{ ... }:
final: prev:
let
  python3PackagesExtended =
    prev.python3Packages
    // {
      xxh = prev.python3Packages.callPackage ../../packages/xxh { };
    };
in
{
  python3Packages = python3PackagesExtended;
  xxh = python3PackagesExtended.xxh;
}

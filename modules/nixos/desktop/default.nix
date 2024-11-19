{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # ./awesome
  ];

  environment.systemPackages = with pkgs; [
    autorandr
    arandr
  ];

}

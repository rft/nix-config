{
  pkgs,
  config,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    #xonsh
    nur.repos.xonsh-xontribs.xontrib-prompt-starship
    #nur.repos.xonsh-xontribs.xontrib-fish-completer
  ];


}

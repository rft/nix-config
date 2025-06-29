{
  pkgs,
  config,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    xonsh
    nur.repos.xonsh-xontribs.xontrib-prompt-starship
    #nur.repos.xonsh-xontribs.xontrib-fish-completer
    #nur.repos.xonsh-xontribs.xonsh
  ];

  programs.xonsh = {
    enable = true;
    extraPackages =
      ps: with ps; [
        numpy
        requests
        xonsh.xontribs.xontrib-vox
        #xonsh.xontribs.xontrib-prompt-starship
      ];
  };

}

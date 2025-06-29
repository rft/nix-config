{ pkgs, ... }:
{
  home.sessionVariables = {
    BROWSER = "floorp";
  };

  home.packages = [ pkgs.ff2mpv-rust ];
  programs.floorp = {
    enable = true;
    profiles = {
      main = {
        id = 0;
        isDefault = true;
        containersForce = true;
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          sponsorblock
          auto-tab-discard
          bitwarden
          darkreader
          decentraleyes
          clearurls
          old-reddit-redirect
          privacy-badger
          reddit-enhancement-suite
          stylus
          temporary-containers
          multi-account-containers
          dearrow
          betterttv
          violentmonkey
          return-youtube-dislikes
          terms-of-service-didnt-read
        ];
      };
    };
  };
}

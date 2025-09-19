{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.modules.home.applications.enable {
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
          # Search here -> https://nur.nix-community.org/repos/rycee/
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            auto-tab-discard
            betterttv
            bitwarden
            clearurls
            darkreader
            dearrow
            decentraleyes
            gesturefy
            multi-account-containers
            old-reddit-redirect
            privacy-badger
            reddit-enhancement-suite
            return-youtube-dislikes
            sidebery
            sponsorblock
            stylus
            temporary-containers
            terms-of-service-didnt-read
            videospeed
            vimium-c
            violentmonkey
            ublock-origin
          ];
        };
      };
    };
  };
}

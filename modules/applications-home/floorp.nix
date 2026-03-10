{ delib, ... }:
delib.module {
  name = "applications.floorp";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    applications.floorp.enable = myconfig.applications.enable or false;
  };

  home.ifEnabled = { pkgs, ... }: {
    home.sessionVariables.BROWSER = "floorp";

    home.packages = [ pkgs.ff2mpv-rust ];

    programs.floorp = {
      enable = true;
      package = pkgs.floorp-bin;
      profiles.main = {
        id = 0;
        isDefault = true;
        containersForce = true;
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          auto-tab-discard
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
}

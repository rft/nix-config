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
          settings = {
            # Keep Home Manager installed extensions enabled after launch.
            "extensions.autoDisableScopes" = 0;
            "extensions.enabledScopes" = 15;
          };
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

    home.activation.floorpEnableExtensions =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        profile_dir="${config.home.homeDirectory}/.floorp/main"
        extensions_json="$profile_dir/extensions.json"
        addon_startup="$profile_dir/addonStartup.json.lz4"
        if [ -f "$extensions_json" ]; then
          tmp_file="$extensions_json.hm-tmp"
          ${pkgs.jq}/bin/jq '
            if has("addons") then
              .addons = (.addons
                | map(if .foreignInstall == true then
                    .userDisabled = false
                    | .active = true
                  else .
                  end))
            else .
            end
          ' "$extensions_json" > "$tmp_file" && mv "$tmp_file" "$extensions_json"
        fi
        if [ -f "$addon_startup" ]; then
          rm -f "$addon_startup"
        fi
      '';
  };
}

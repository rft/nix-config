{
  delib,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  t = import ../../lib/titanium-palette.nix;

  rgb =
    hex:
    map (i: lib.fromHexString (builtins.substring i 2 hex)) [
      1
      3
      5
    ];

  # Loaded with --load-extension so the UI follows the titanium palette.
  titaniumTheme = pkgs.writeTextFile {
    name = "helium-titanium-theme";
    destination = "/manifest.json";
    text = builtins.toJSON {
      manifest_version = 3;
      name = "Titanium";
      version = "1.0";
      theme.colors = lib.mapAttrs (_: rgb) {
        frame = t.darkTitanium;
        frame_inactive = t.darkTitanium;
        toolbar = t.brushedTitanium;
        tab_text = t.brightAluminum;
        tab_background_text = t.dimAluminum;
        tab_background_text_inactive = t.comment;
        bookmark_text = t.dimAluminum;
        toolbar_text = t.brightAluminum;
        toolbar_button_icon = t.dimAluminum;
        omnibox_background = t.borderMuted;
        omnibox_text = t.brightAluminum;
        ntp_background = t.brushedTitanium;
        ntp_text = t.brightAluminum;
        ntp_link = t.electricBlue;
      };
    };
  };

  # Toolbar order, left to right. uBlock Origin is Helium's built-in component extension.
  pinnedExtensions = [
    "edacconmaakjimmfgnblocblbcdcpbko" # Session Buddy
    "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
    "blockjmkbacgjkknlgpkjjiijinjdanf" # uBlock Origin
    "ldgfbffkinooeloadekpmfoklnobpien" # Raindrop.io
    "jinjaccalgkegednnccohejagnlnfdag" # Violentmonkey
  ];
in
delib.module {
  name = "applications.helium";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    applications.helium.enable = lib.mkDefault (myconfig.applications.enable or false);
  };

  # Upstream flake is Linux-only. Policies go to /etc/{chromium,helium}/policies/managed,
  # since Chromium doesn't reliably read user-level policy files.
  nixos.always.imports = [ inputs.helium.nixosModules.default ];

  nixos.ifEnabled = {
    programs.helium = {
      enable = true;
      flags = [
        "--force-dark-mode"
        "--load-extension=${titaniumTheme}"
      ];
      policies = {
        DefaultSearchProviderEnabled = true;
        DefaultSearchProviderName = "Kagi";
        DefaultSearchProviderKeyword = "kagi.com";
        DefaultSearchProviderSearchURL = "https://kagi.com/search?q={searchTerms}";
        DefaultSearchProviderSuggestURL = "https://kagi.com/api/autosuggest?q={searchTerms}";

        SiteSearchSettings = [
          {
            name = "Subreddit";
            shortcut = "r";
            url = "https://www.reddit.com/r/{searchTerms}";
          }
          {
            name = "YouTube";
            shortcut = "y";
            url = "https://www.youtube.com/results?search_query={searchTerms}";
          }
          {
            name = "Amazon";
            shortcut = "a";
            url = "https://www.amazon.com/s?k={searchTerms}";
          }
        ];

        NewTabPageLocation = "about:blank";

        # Force-installed extensions are hidden under the puzzle menu by default.
        # Policy can pin but not order them; the order is seeded by the activation below.
        ExtensionSettings =
          lib.genAttrs (lib.remove "blockjmkbacgjkknlgpkjjiijinjdanf" pinnedExtensions)
            (_: {
              toolbar_pin = "force_pinned";
            });

        # Chrome Web Store IDs. uBlock Origin ships built into Helium.
        ExtensionInstallForcelist = [
          "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
          "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
          "enamippconapkdmgfgjchkhakpfinmaj" # DeArrow
          "ponfpcnoihfmfllpaingbgckeeldkhle" # Enhancer for YouTube
          "fcjmgeodgobggcppooncdagfkogfffdm" # Imagus Reborn
          "fkagelmloambgokoeokbpihmgpkbgbfm" # Indie Wiki Buddy
          "halllmdjninjohpckldgkaolbhgkfnpe" # Karamel
          "oadlabdleegopgjlkcmjjogeaceagbie" # Nyan Cat Extension
          "dneaehbmnbhcippjikoajpoabadpodje" # Old Reddit Redirect
          "ldgfbffkinooeloadekpmfoklnobpien" # Raindrop.io
          "kbmfpngjjgdllneeigpgjifpgocmfgmb" # Reddit Enhancement Suite
          "gebbhagfogifgggkldgodflihgfeippi" # Return YouTube Dislike
          "edacconmaakjimmfgnblocblbcdcpbko" # Session Buddy
          "mpiodijhokgodhhofbcjdecpffjipkle" # SingleFile
          "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
          "kdplapeciagkkjoignnkfpbfkebcfbpb" # uAutoPagerize
          "hfjbmagddngcpeloejdejnfgbamkjaeg" # Vimium C
          "jinjaccalgkegednnccohejagnlnfdag" # Violentmonkey
        ];
      };
    };
  };

  # Helium rewrites Preferences on exit, so only touch it while the browser is closed.
  home.ifEnabled = lib.mkIf pkgs.stdenv.isLinux {
    home.activation.heliumPinnedExtensions =
      inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ]
        ''
          prefs="$HOME/.config/net.imput.helium/Default/Preferences"
          if [ -f "$prefs" ] && ! ${pkgs.procps}/bin/pgrep -u "$USER" -x helium >/dev/null; then
            tmp=$(mktemp)
            ${lib.getExe pkgs.jq} --argjson ids '${builtins.toJSON pinnedExtensions}' \
              '.extensions.pinned_extensions = $ids' "$prefs" > "$tmp" && run mv "$tmp" "$prefs"
          fi
        '';
  };
}

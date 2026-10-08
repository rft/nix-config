{ delib, lib, pkgs, ... }:
delib.module {
  name = "applications.creative";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    applications.creative.enable = lib.mkDefault (myconfig.applications.enable or false);
  };

  nixos.ifEnabled = {
    environment.systemPackages = with pkgs; [
      aseprite
      blender
      blender-mcp
      kdePackages.kdenlive
      krita
      reaper
    ];
  };

  darwin.ifEnabled = { };

  # Blender only loads the MCP add-on from its per-version extensions dir; link
  # the copy shipped with blender-mcp so add-on and server stay in sync. It still
  # has to be enabled once in Preferences > Add-ons (stored in userpref.blend).
  home.ifEnabled = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    xdg.configFile."blender/${lib.versions.majorMinor pkgs.blender.version}/extensions/user_default/mcp".source =
      "${pkgs.blender-mcp}/share/blender-mcp/addon";
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.modules.home.applications.enable {
    home.packages = [ pkgs.kando ];

    xdg.configFile."kando/menus.json".text = ''
      {
        "version": "2.1.0",
        "menus": [
          {
            "root": {
              "name": "Noctalia Menu",
              "type": "submenu",
              "icon": "",
              "iconTheme": "",
              "children": [
                {
                  "name": "Terminal",
                  "type": "command",
                  "icon": "",
                  "iconTheme": "",
                  "data": {
                    "command": "kitty",
                    "delayed": false
                  }
                },
                {
                  "name": "Browser",
                  "type": "command",
                  "icon": "",
                  "iconTheme": "",
                  "data": {
                    "command": "floorp",
                    "delayed": false
                  }
                }
              ]
            }
          }
        ]
      }
    '';
  };
}

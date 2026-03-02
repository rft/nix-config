{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.modules.home.applications.enable {
    home.packages = [ pkgs.kando ];

    systemd.user.services.kando = {
      Unit = {
        Description = "Kando radial menu";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${lib.getExe pkgs.kando} --background";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

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

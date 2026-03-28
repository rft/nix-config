{ delib, inputs, ... }:
delib.module {
  name = "desktop.paneru";

  options = delib.singleEnableOption false;

  home.always.imports = [ inputs.paneru.homeModules.paneru ];

  home.ifEnabled = {
    services.paneru = {
      enable = true;
      settings = {
        options = {
          focus_follows_mouse = true;
          mouse_follows_focus = true;
        };
        bindings = {
          window_focus_west = "cmd - h";
          window_focus_east = "cmd - l";
          window_focus_north = "cmd - k";
          window_focus_south = "cmd - j";
          window_swap_west = "shift + cmd - h";
          window_swap_east = "shift + cmd - l";
          window_swap_north = "shift + cmd - k";
          window_swap_south = "shift + cmd - j";
          window_resize = "alt - r";
          window_shrink = "alt - s";
          window_fullwidth = "alt - f";
          window_center = "alt - c";
          window_manage = "ctrl + alt - t";
          window_stack = "alt - ]";
          window_unstack = "alt - [";
          quit = "ctrl + alt - q";
        };
      };
    };
  };
}

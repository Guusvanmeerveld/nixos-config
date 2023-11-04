{ config, lib, pkgs, ... }:

let
  #  Super / Windows key
  mod = "Mod4";
in
{
  xsession.windowManager.i3 = {
    enable = true;

    config = {
      modifier = mod;

      gaps = {
        inner = 5;
      };

      colors = { };

      assigns =
        {
          "1: web" = [{
            class = "^librewolf$";
          }];
          "2: code" = [{
            class = "^VSCodium$";
          }];

        };

      keybindings = lib.mkOptionDefault
        {
          "${mod}+space" = "exec ${pkgs.rofi}/bin/rofi -show run";
          "${mod}+Return" = "exec ${pkgs.kitty}/bin/kitty";

          "${mod}+w" = "kill";

          "${mod}+f" = "fullscreen toggle";

          # Focus
          "${mod}+h" = "focus left";
          "${mod}+j" = "focus down";
          "${mod}+k" = "focus up";
          "${mod}+l" = "focus right";

          # Move
          "${mod}+Shift+h" = "move left";
          "${mod}+Shift+j" = "move down";
          "${mod}+Shift+k" = "move up";
          "${mod}+Shift+l" = "move right";

          # Applications
          "${mod}+v" = "[ class=^librewolf$ ] focus";
          "${mod}+c" = "[ class=^VSCodium$ ] focus";
          "${mod}+g" = "[ class=^psst-gui$ ] focus";
        };

    };
  };
}

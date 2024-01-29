args @ { config, lib, pkgs, ... }:

let
  #  Super / Windows key
  mod = "Mod4";

  prog = {
    librewolf = "librewolf";
    vscodium = "VSCodium";
    vscode = "Code";
    psst = "Psst-gui";
    spotify = "Spotify";
    cinny = "Cinny";
    discord = "ArmCord";
    steam = "steam";
  };

  colors = {
    background = {
      primary = "#151515";
      secondary = "#212121";

      alt = {
        primary = "#232323";
        secondary = "#353535";
      };
    };

    text = {
      primary = "#eeeeee";
      secondary = "#cecece";
    };

    ok = "#98c379";
    warn = "#e06c75";
    error = "#be5046";

    primary = "#61afef";
  };

  font = {
    primary = "Fira Code";
  };

in
{

  imports = [

    (
      import ./programs/services/polybar.nix
        (
          args
          // { colors = colors; font = font; }
        )
    )
    (
      import ./programs/services/dunst.nix
        (
          args
          // { colors = colors; font = font; }
        )
    )
    (
      import ./programs/graphical/rofi.nix
        (
          args
          // { colors = colors; font = font; }
        )
    )
  ];

  services = {
    picom.enable = true;
    betterlockscreen = { enable = true; };
  };

  xsession.windowManager.i3 = {
    enable = true;

    extraConfig = ''
      title_align center
      default_border pixel 1
    '';

    config = {
      modifier = mod;
      workspaceAutoBackAndForth = true;

      startup = [
        {
          command = "systemctl --user restart polybar";
          always = true;
          notification = false;
        }
        {
          command = "betterlockscreen -l blur";
          notification = false;
        }
      ];

      menu = "${pkgs.rofi}/bin/rofi";

      fonts = {
        names = [ font.primary ];
        size = 12.0;
      };

      bars = [ ];

      gaps = {
        inner = 5;
      };

      colors = {
        focused = {
          background = colors.background.primary;
          border = colors.background.secondary;
          childBorder = colors.background.secondary;
          indicator = colors.background.secondary;
          text = colors.text.primary;
        };
        unfocused = {
          background = colors.background.alt.primary;
          border = colors.background.alt.secondary;
          childBorder = colors.background.alt.secondary;
          indicator = colors.background.alt.secondary;
          text = colors.text.secondary;
        };
        urgent = {
          background = colors.background.primary;
          border = colors.warn;
          childBorder = colors.warn;
          indicator = colors.warn;
          text = colors.text.primary;
        };

      };

      workspaceOutputAssign = [
        {
          output = "primary";
          workspace = "3: web";
        }
        {
          output = "primary";
          workspace = "4: code";
        }
        {
          output = "primary";
          workspace = "5: games";
        }
      ];

      assigns =
        {
          "1: messaging" = [
            {
              class = "^${prog.discord}$";
            }
            {
              class = "^${prog.cinny}$";
            }
          ];

          "2: music" = [
            {
              class = "^${prog.psst}$";
            }
            {
              class = "^${prog.spotify}$";
            }
          ];

          "3: web" = [{
            class = "^${prog.librewolf}$";
          }];

          "4: code" = [
            {
              class = "^${prog.vscodium}$";
            }
            {
              class = "^${prog.vscode}$";
            }
          ];

          "5: games" = [{
            class = "^${prog.steam}$";
          }];
        };

      keybindings = lib.mkOptionDefault
        {
          "${mod}+space" = "exec ${pkgs.rofi}/bin/rofi -show combi";
          "${mod}+Return" = "exec ${pkgs.kitty}/bin/kitty";

          "${mod}+w" = "kill";

          "${mod}+f" = "fullscreen toggle";

          "${mod}+e" = "exec ${pkgs.xfce.thunar}/bin/thunar";

          "${mod}+0" = "exec --no-startup-id betterlockscreen -l dim";

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

          # Media keys
          "XF86AudioPlay" = "exec playerctl play";
          "XF86AudioStop" = "exec playerctl pause";
          "XF86AudioPause" = "exec playerctl play-pause";
          "XF86AudioNext" = "exec playerctl next";
          "XF86AudioPrev" = "exec playerctl previous";

          "XF86MonBrightnessUp" = "exec light -A 5";
          "XF86MonBrightnessDown" = "exec light -U 5";

          "Print" = "exec flameshot gui";

          # Applications
          "${mod}+z" = "[ class=^${prog.discord}$ ] focus";
          "${mod}+x" = "[ class=^${prog.spotify}$ ] focus";
          "${mod}+c" = "[ class=^${prog.librewolf}$ ] focus";
          "${mod}+v" = "[ class=^${prog.vscodium}$ ] focus";
          "${mod}+b" = "[ class=^${prog.steam}$ ] focus";
        };

    };
  };
}

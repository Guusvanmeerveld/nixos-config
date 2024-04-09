{
  lib,
  config,
  pkgs,
  ...
}: let
  theme = config.custom.wm.theme;
  cfg = config.custom.wm.i3;

  prog = {
    librewolf = "librewolf";
    firefox = "firefox";
    vscodium = "VSCodium";
    vscode = "Code";
    psst = "Psst-gui";
    spotify = "Spotify";
    schildichat = "SchildiChat";
    discord = "ArmCord";
    steam = "steam";
  };

  betterlockscreen = {
    pkg = pkgs.betterlockscreen;
    command = "${pkgs.betterlockscreen}/bin/betterlockscreen";
  };
in {
  options = {
    custom.wm.i3 = {
      enable = lib.mkEnableOption "Enable i3 wm";

      mod = lib.mkOption {
        type = lib.types.str;
        description = "The modifier key to be used";
        #  Super / Windows key
        default = "Mod4";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [playerctl];

    custom.applications = {
      graphical = {
        rofi.enable = true;
      };

      services = {
        dunst.enable = true;
        polybar.enable = true;
      };
    };

    services = {
      picom.enable = true;

      betterlockscreen = {
        enable = true;
        package = betterlockscreen.pkg;
      };
    };

    xsession.windowManager.i3 = {
      enable = true;

      extraConfig = ''
        title_align center
        default_border pixel 1
      '';

      config = {
        modifier = cfg.mod;
        workspaceAutoBackAndForth = true;

        startup = [
          {
            command = "systemctl --user restart polybar";
            always = true;
            notification = false;
          }
          {
            command = "${betterlockscreen.command} -l blur";
            notification = false;
          }
        ];

        menu = "${pkgs.rofi}/bin/rofi";

        fonts = {
          names = [theme.font.name];
          size = 12.0;
        };

        bars = [];

        gaps = {
          inner = 5;
        };

        colors = {
          focused = {
            background = theme.background.primary;
            border = theme.background.secondary;
            childBorder = theme.background.secondary;
            indicator = theme.background.secondary;
            text = theme.text.primary;
          };
          unfocused = {
            background = theme.background.alt.primary;
            border = theme.background.alt.secondary;
            childBorder = theme.background.alt.secondary;
            indicator = theme.background.alt.secondary;
            text = theme.text.secondary;
          };
          urgent = {
            background = theme.background.primary;
            border = theme.warn;
            childBorder = theme.warn;
            indicator = theme.warn;
            text = theme.text.primary;
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

        assigns = {
          "1: messaging" = [
            {
              class = "^${prog.discord}$";
            }
            {
              class = "^${prog.schildichat}$";
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

          "3: web" = [
            {
              class = "^${prog.librewolf}$";
            }
            {
              class = "^${prog.firefox}$";
            }
          ];

          "4: code" = [
            {
              class = "^${prog.vscodium}$";
            }
            {
              class = "^${prog.vscode}$";
            }
          ];

          "5: games" = [
            {
              class = "^${prog.steam}$";
            }
          ];
        };

        keybindings = lib.mkOptionDefault {
          "${cfg.mod}+space" = "exec ${pkgs.rofi}/bin/rofi -show combi";
          "${cfg.mod}+Return" = "exec ${pkgs.kitty}/bin/kitty";

          "${cfg.mod}+w" = "kill";

          "${cfg.mod}+f" = "fullscreen toggle";
          "${cfg.mod}+g" = "layout toggle splitv splith";
          "${cfg.mod}+s" = "floating toggle";
          "${cfg.mod}+t" = "split toggle";

          "${cfg.mod}+e" = "exec ${pkgs.xfce.thunar}/bin/thunar";

          "${cfg.mod}+0" = "exec --no-startup-id ${betterlockscreen.command} -l dim";

          # Focus
          "${cfg.mod}+h" = "focus left";
          "${cfg.mod}+j" = "focus down";
          "${cfg.mod}+k" = "focus up";
          "${cfg.mod}+l" = "focus right";

          # Move
          "${cfg.mod}+Shift+h" = "move left";
          "${cfg.mod}+Shift+j" = "move down";
          "${cfg.mod}+Shift+k" = "move up";
          "${cfg.mod}+Shift+l" = "move right";

          # Media keys
          "XF86AudioPlay" = "exec playerctl play";
          "XF86AudioStop" = "exec playerctl pause";
          "XF86AudioPause" = "exec playerctl play-pause";
          "XF86AudioNext" = "exec playerctl next";
          "XF86AudioPrev" = "exec playerctl previous";

          "XF86MonBrightnessUp" = "exec light -A 5";
          "XF86MonBrightnessDown" = "exec light -U 5";

          "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";

          "Print" = "exec flameshot gui";

          # Applications
          "${cfg.mod}+z" = "[ class=^${prog.discord}$ ] focus";
          "${cfg.mod}+x" = "[ class=^${prog.spotify}$ ] focus";
          "${cfg.mod}+c" = "[ class=^${prog.firefox}$ ] focus";
          "${cfg.mod}+v" = "[ class=^${prog.vscodium}$ ] focus";
          "${cfg.mod}+b" = "[ class=^${prog.steam}$ ] focus";
        };
      };
    };
  };
}

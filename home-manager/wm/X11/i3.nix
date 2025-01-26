{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.x11.i3;

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
in {
  options = {
    custom.wm.x11.i3 = {
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
    home.packages = with pkgs; [playerctl light pulseaudio];

    services = {
      picom.enable = true;
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

        startup =
          lib.optional config.services.betterlockscreen.enable {
            command = "${config.services.betterlockscreen.package}/bin/betterlockscreen -l blur";
            notification = false;
          }
          ++ lib.optional config.services.polybar.enable {
            command = "systemctl --user restart polybar";
            always = true;
            notification = false;
          };

        menu = lib.mkIf config.programs.rofi.enable "${pkgs.rofi}/bin/rofi";

        fonts = {
          names = ["Fira Code"];
          size = 12.0;
        };

        bars = [];

        gaps = {
          inner = 5;
        };

        colors = {
          focused = {
            background = "#${config.colorScheme.palette.base00}";
            border = "#${config.colorScheme.palette.base02}";
            childBorder = "#${config.colorScheme.palette.base02}";
            indicator = "#${config.colorScheme.palette.base02}";
            text = "#${config.colorScheme.palette.base06}";
          };
          unfocused = {
            background = "#${config.colorScheme.palette.base05}";
            border = "#${config.colorScheme.palette.base01}";
            childBorder = "#${config.colorScheme.palette.base01}";
            indicator = "#${config.colorScheme.palette.base01}";
            text = "#${config.colorScheme.palette.base05}";
          };
          urgent = {
            background = "#${config.colorScheme.palette.base00}";
            border = "#${config.colorScheme.palette.base0A}";
            childBorder = "#${config.colorScheme.palette.base0A}";
            indicator = "#${config.colorScheme.palette.base0A}";
            text = "#${config.colorScheme.palette.base06}";
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
          "${cfg.mod}+Return" = lib.mkIf config.programs.kitty.enable "exec ${pkgs.kitty}/bin/kitty";

          "${cfg.mod}+w" = "kill";

          "${cfg.mod}+f" = "fullscreen toggle";
          "${cfg.mod}+g" = "layout toggle splitv splith";
          "${cfg.mod}+s" = "floating toggle";
          "${cfg.mod}+t" = "split toggle";

          "${cfg.mod}+e" = "exec ${pkgs.xfce.thunar}/bin/thunar";

          "${cfg.mod}+0" = lib.mkIf config.services.betterlockscreen.enable "exec --no-startup-id ${config.services.betterlockscreen.package}/bin/betterlockscreen -l dim";

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

          "Print" = lib.mkIf config.services.flameshot.enable "exec flameshot gui";

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

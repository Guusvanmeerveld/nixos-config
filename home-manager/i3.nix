{ config, lib, pkgs, ... }:

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
    discord = "discord";
    steam = "steam";
  };

  colors = {
    background = {
      primary = "#191919";
      secondary = "#383838";

      alt = {
        primary = "#232323";
        secondary = "#212121";
      };
    };

    text = {
      primary = "#eeeeee";
      secondary = "#cecece";
    };

    ok = "#98c379";
    warn = "#e06c75";
    error = "#be5046";

    primary = "#e5c07b";

  };

  font = {
    primary = "Fira Code";
  };

in
{
  services.polybar = {
    enable = true;
    package = pkgs.polybarFull;
    script = ''
      # Terminate already running bar instances
      ${pkgs.killall}/bin/killall -q ${pkgs.polybarFull}/bin/polybar

      # Wait until the processes have been shut down
      while ${pkgs.procps}/bin/pgrep -x ${pkgs.polybarFull}/bin/polybar > /dev/null; do sleep 1; done

      screens=$(${pkgs.xorg.xrandr}/bin/xrandr --listactivemonitors | ${pkgs.gnugrep}/bin/grep -v "Monitors" | ${pkgs.coreutils}/bin/cut -d" " -f6)

      if [[ $(${pkgs.xorg.xrandr}/bin/xrandr --listactivemonitors | ${pkgs.gnugrep}/bin/grep -v "Monitors" | ${pkgs.coreutils}/bin/cut -d" " -f4 | cut -d"+" -f2- | uniq | wc -l) == 1 ]]; then
        MONITOR=$(${pkgs.polybarFull}/bin/polybar --list-monitors | ${pkgs.gnugrep}/bin/grep -d":" -f1) TRAY_POS=right ${pkgs.polybarFull}/bin/polybar top &
      else
        primary=$(${pkgs.xorg.xrandr}/bin/xrandr --query | ${pkgs.gnugrep}/bin/grep primary | ${pkgs.coreutils}/bin/cut -d" " -f1)

        for m in $screens; do
          if [[ $primary == $m ]]; then
          MONITOR=$m TRAY_POS=right ${pkgs.polybarFull}/bin/polybar top &
          else
          MONITOR=$m TRAY_POS=none ${pkgs.polybarFull}/bin/polybar top &
          fi
        done
      fi
    '';

    settings = {
      "bar/top" = {
        monitor = "\${env:MONITOR:primary}";
        width = "100%";
        height = 43;
        offset-x = "0%";
        offset-y = "0%";
        radius = "0.0";
        fixed-center = true;

        background = colors.background.primary;
        foreground = colors.text.primary;

        line-size = 4;
        line-color = colors.text.primary;

        border-size = 0;
        border-color = colors.background.secondary;

        padding-left = 0;
        padding-right = 0;

        module-margin-left = 0;
        module-margin-right = 0;

        font-0 = "${font.primary}:fontformat=truetype:size=12;1";
        font-1 = "FontAwesome:fontformat=truetype:size=9;1";

        modules-left = "i3 xwindow";
        modules-center = "date";
        modules-right = "battery";

        tray-position = "\${env:TRAY_POS:right}";
        tray-padding = 9;
        tray-offset-y = "0%";
        tray-offset-x = "0%";
        tray-maxsize = 18;
        tray-detached = false;
        tray-background = colors.background.primary;
        tray-underline = colors.primary;

        wm-restack = "i3";

      };

      "module/i3" = {
        type = "internal/i3";

        label-mode = "%mode%";
        label-mode-padding = 2;
        label-mode-background = colors.primary;
      };

      "module/date" = {
        type = "internal/date";
        interval = 5;

        date = "%a %b %d";
        time = "%H:%M";

        format-prefix-foreground = colors.text.primary;
        format-underline = colors.primary;

        label = "%date%, %time%";
      };

    };
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
          "${mod}+space" = "exec ${pkgs.rofi}/bin/rofi -show run";
          "${mod}+Return" = "exec ${pkgs.kitty}/bin/kitty";

          "${mod}+w" = "kill";

          "${mod}+f" = "fullscreen toggle";

          "${mod}+0" = "exec --no-startup-id i3lock 3 5";

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
          "${mod}+z" = "[ class=^${prog.discord}$ ] focus";
          "${mod}+x" = "[ class=^${prog.spotify}$ ] focus";
          "${mod}+c" = "[ class=^${prog.librewolf}$ ] focus";
          "${mod}+v" = "[ class=^${prog.vscode}$ ] focus";
          "${mod}+b" = "[ class=^${prog.steam}$ ] focus";
        };

    };
  };
}

{ pkgs, colors, font, ... }: {
  systemd.user.services.polybar = {
    Install.WantedBy = [ "graphical-session.target" ];
  };


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
        font-1 = "Font Awesome 6 Free,Font Awesome 6 Free Solid:style=Solid:size=12;1";

        modules-left = "i3";
        modules-center = "date";
        modules-right = "pulseaudio wired-network wireless-network battery";

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

        index-sort = true;
        strip-wsnumbers = true;
        pin-workspaces = true;

        format = "<label-state> <label-mode>";

        label-focused = "%index%";
        label-focused-foreground = colors.text.primary;
        label-focused-background = colors.background.secondary;
        label-focused-underline = colors.primary;
        label-focused-padding = 2;

        label-mode = "%mode%";
        label-mode-padding = 2;
        label-mode-background = colors.primary;

        label-unfocused = "%index%";
        label-unfocused-padding = 2;
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

      "module/wired-network" =
        {
          type = "internal/network";
          interface-type = "wired";

          interval = 3;

          format-connected = "<label-connected>";

          label-connected = "";
          label-connected-padding = 2;
          label-connected-foreground = colors.text.primary;

          format-disconnected = "<label-disconnected>";

          label-disconnected = "";
          label-disconnected-padding = 2;
          label-disconnected-foreground = colors.warn;
        };

      "module/wireless-network" =
        {
          type = "internal/network";
          interface-type = "wireless";

          interval = 3;
        };

      "module/pulseaudio" = {
        type = "internal/pulseaudio";

        use-ui-max = false;
        interval = 5;

        format-volume = "<ramp-volume> <label-volume>";
        format-volume-padding = 2;

        label-muted = "";

        ramp-volume-0 = "";
        ramp-volume-1 = "";
        ramp-volume-2 = "";

        click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
      };
    };
  };

}

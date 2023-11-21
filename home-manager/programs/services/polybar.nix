{ pkgs, colors, font, ... }: {
  systemd.user.services.polybar = {
    Install.WantedBy = [ "graphical-session.target" ];
  };

  services.polybar = {
    enable = true;
    package = pkgs.polybar.override
      {
        i3Support = true;
        alsaSupport = true;
        pulseSupport = true;
      };

    script = ''
      screens=$(${pkgs.xorg.xrandr}/bin/xrandr --listactivemonitors | ${pkgs.gnugrep}/bin/grep -v "Monitors" | ${pkgs.coreutils}/bin/cut -d" " -f6)

      if [[ $(${pkgs.xorg.xrandr}/bin/xrandr --listactivemonitors | ${pkgs.gnugrep}/bin/grep -v "Monitors" | ${pkgs.coreutils}/bin/cut -d" " -f4 | cut -d"+" -f2- | uniq | wc -l) == 1 ]]; then
        MONITOR=$(polybar --list-monitors | ${pkgs.gnugrep}/bin/grep -d":" -f1) TRAY_POS=right polybar top &
      else
        primary=$(${pkgs.xorg.xrandr}/bin/xrandr --query | ${pkgs.gnugrep}/bin/grep primary | ${pkgs.coreutils}/bin/cut -d" " -f1)

        for m in $screens; do
          if [[ $primary == $m ]]; then
          MONITOR=$m TRAY_POS=right polybar top &
          else
          MONITOR=$m TRAY_POS=none polybar top &
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
        modules-right = "pulseaudio wired-network wireless-network backlight battery";

        tray-position = "\${env:TRAY_POS:right}";
        tray-padding = 9;
        tray-offset-y = "0%";
        tray-offset-x = "0%";
        tray-maxsize = 18;
        tray-detached = false;
        tray-background = colors.background.primary;
        tray-underline = colors.primary;

        # wm-restack = "i3";
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

      # "module/media-player" = {

      #   type = "custom/script";
      #   exec = "./mpris-tail.py -f '{artist} - {title}'"
      #     tail = true

      #   };

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
          label-connected-foreground = colors.text.primary;
          format-connected-padding = 1;

          format-disconnected = "<label-disconnected>";

          label-disconnected = "";
          label-disconnected-foreground = colors.warn;
          format-disconnected-padding = 1;
        };

      "module/wireless-network" =
        {
          type = "internal/network";
          interface-type = "wireless";

          format-connected-padding = 1;
          format-connected = "<label-connected>";

          label-connected = "";
          label-connected-foreground = colors.text.primary;

          format-disconnected = "<label-disconnected>";
          format-disconnected-padding = 1;

          label-disconnected = "";
          label-disconnected-foreground = colors.warn;

          click-right = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";

          interval = 3;
        };

      "module/pulseaudio" = {
        type = "internal/pulseaudio";

        use-ui-max = false;
        interval = 5;

        format-volume = "<ramp-volume> <label-volume>";
        format-volume-padding = 1;

        label-muted = "";
        format-muted-padding = 1;

        ramp-volume-0 = "";
        ramp-volume-1 = "";
        ramp-volume-2 = "";

        click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
      };

      "module/battery" = {
        type = "internal/battery";

        low-at = 10;

        # $ ls -1 /sys/class/power_supply/
        battery = "BAT1";
        adapter = "ACAD";

        time-format = "%H:%M";

        format-charging = "<animation-charging> <label-charging>";
        format-charging-padding = 1;

        format-discharging = "<ramp-capacity> <label-discharging>";
        format-discharging-padding = 1;

        label-charging = "%percentage%%";

        label-discharging = "%percentage%%";

        label-low = "%percentage% - %time% left";

        ramp-capacity-0 = "";
        ramp-capacity-1 = "";
        ramp-capacity-2 = "";
        ramp-capacity-3 = "";
        ramp-capacity-4 = "";

        animation-charging-0 = "";
        animation-charging-1 = "";
        animation-charging-2 = "";
        animation-charging-3 = "";
        animation-charging-4 = "";
        # Framerate in milliseconds
        animation-charging-framerate = 750;

        animation-low-0 = "!";
        animation-low-1 = "";
        animation-low-framerate = 1000;
      };

      "module/backlight" = {
        type = "internal/backlight";

        card = "amdgpu_bl0";

        enable-scroll = true;

        format = " <label>";

        format-padding = 1;

        label = "%percentage%%";

      };
    };
  };

}

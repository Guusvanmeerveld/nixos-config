{ lib, config, pkgs, ... }:
let
  cfg = config.custom.applications.services.polybar;
  theme = config.custom.theme;
in
{
  imports = [ ../../theme ];

  options = {
    custom.applications.services.polybar = {
      enable = lib.mkEnableOption "Enable Polybar";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      font-awesome
      networkmanagerapplet
      pavucontrol
      gnused
      coreutils
    ];

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
        MONITOR=$(polybar -m|${pkgs.coreutils}/bin/tail -1|${pkgs.gnused}/bin/sed -e 's/:.*$//g') TRAY_POS=right polybar top &
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

          background = theme.background.primary;
          foreground = theme.text.primary;

          line-size = 4;
          line-color = theme.text.primary;

          border-size = 0;
          border-color = theme.background.secondary;

          padding-left = 0;
          padding-right = 0;

          module-margin-left = 0;
          module-margin-right = 0;

          font-0 = "${theme.font.name}:fontformat=truetype:size=12;1";
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
          tray-background = theme.background.primary;
          tray-underline = theme.primary;

          # wm-restack = "i3";
        };

        "module/i3" = {
          type = "internal/i3";

          index-sort = true;
          strip-wsnumbers = true;
          pin-workspaces = true;

          format = "<label-state> <label-mode>";

          label-focused = "%index%";
          label-focused-foreground = theme.text.primary;
          label-focused-background = theme.background.secondary;
          label-focused-underline = theme.primary;
          label-focused-padding = 2;

          label-mode = "%mode%";
          label-mode-padding = 2;
          label-mode-background = theme.primary;

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

          format-prefix-foreground = theme.text.primary;
          format-underline = theme.primary;

          label = "%date%, %time%";
        };

        "module/wired-network" =
          {
            type = "internal/network";
            interface-type = "wired";

            interval = 3;

            format-connected = "<label-connected>";

            label-connected = "";
            label-connected-foreground = theme.text.primary;
            format-connected-padding = 1;

            format-disconnected = "<label-disconnected>";

            label-disconnected = "";
            label-disconnected-foreground = theme.warn;
            format-disconnected-padding = 1;
          };

        "module/wireless-network" =
          {
            type = "internal/network";
            interface-type = "wireless";

            format-connected-padding = 1;
            format-connected = "<label-connected>";

            label-connected = "";
            label-connected-foreground = theme.text.primary;

            format-disconnected = "<label-disconnected>";
            format-disconnected-padding = 1;

            label-disconnected = "";
            label-disconnected-foreground = theme.warn;

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
  };
}

{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.wayland.bars.waybar;
in {
  options = {
    custom.wm.wayland.bars.waybar = {
      enable = lib.mkEnableOption "Enable waybar status bar";

      font = lib.mkOption {
        type = lib.types.str;
        default = "Fira Code";
        description = "The font to use";
      };

      font-size = lib.mkOption {
        type = lib.types.int;
        default = 16;
        description = "The font size to use";
      };

      features = {
        sway = lib.mkOption {
          type = lib.types.bool;
          default = config.custom.wm.default.name == "sway";
          description = "Enable sway support";
        };

        battery = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable battery support";
        };

        tray = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable tray support";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [font-awesome];

    programs.waybar = {
      enable = true;

      style = let
        bg-color = "#${config.colorScheme.palette.base00}";
        alt-bg-color = "#${config.colorScheme.palette.base01}";

        font-color = "#${config.colorScheme.palette.base05}";
        alt-font-color = "#${config.colorScheme.palette.base04}";

        focused-color = "#${config.colorScheme.palette.base0D}";

        # status-color = "#${config.colorScheme.palette.base0B}";

        font-size = "${toString cfg.font-size}px";
      in ''
        * {
          border: none;
          border-radius: 0;
          font-family: ${cfg.font}, 'Font Awesome 6 Free Solid', monospace;
          font-size: ${font-size};
        }

        window#waybar {
          background: ${bg-color};
          border-bottom: 2px solid ${alt-bg-color};
          color: ${font-color};
        }

        tooltip {
          background: ${bg-color};
          border: 1px solid ${alt-bg-color};
        }

        tooltip label {
          color: ${font-color};
        }

        #workspaces button {
          padding: 0 5px;
          color: ${font-color};
          border-bottom: 2px solid transparent;
        }

        #workspaces button.focused {
          background: ${alt-bg-color};
          color: ${alt-font-color};
          border-bottom: 2px solid ${focused-color};
        }

        #network, #pulseaudio, #privacy, #custom-power {
          padding: 0 10px;
        }

        .not-power {
          margin-right: 5px;
        }

        #tray {
          background: ${alt-bg-color};
          border-radius: 3px;
          padding: 0 10px;
          margin-left: 5px;
          margin-right: 5px;
        }

        #clock {
          border-bottom: 2px solid ${focused-color};
        }
      '';

      settings = {
        main = {
          layer = "top";
          position = "top";

          height = 36;

          modules-left = lib.optional cfg.features.sway "sway/workspaces";
          modules-center = ["clock"];
          modules-right =
            ["privacy" "pulseaudio" "network"]
            ++ lib.optional cfg.features.battery "battery"
            ++ lib.optional cfg.features.tray "tray"
            ++ ["group/group-power"];

          "sway/workspaces" = {
            disable-scroll = true;
          };

          "clock" = {
            format = "{:%a %b %d, %H:%M}";
            tooltip = true;
            tooltip-format = "<tt><small>{calendar}</small></tt>";

            calendar = {
              format = {
                months = "<span color='#${config.colorScheme.palette.base08}'><b>{}</b></span>";
              };
            };
          };

          "privacy" = {
            icon-spacing = 4;
            icon-size = 18;
            transition-duration = 250;
            # modules = [
            #   {type = "screenshare";}
            #   {type = "audio-in";}
            # ];
          };

          "pulseaudio" = {
            format = "{icon}";
            format-muted = "";
            format-icons = ["" "" ""];

            tooltip-format = "{volume}%";

            scroll-step = 5;

            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          };

          "network" = {
            interval = 5;

            format-ethernet = "";
            format-wifi = "";
            format-disconnected = "";

            tooltip-format-ethernet = "{bandwidthUpBytes} up | {bandwidthDownBytes} down";
            tooltip-format-wifi = "{essid}";
            tooltip-format-disconnected = "Disconnected from the internet";
          };

          "battery" = {
            format = "{icon}";

            states = {
              warning = 20;
              critical = 5;
            };

            format-icons = ["" "" "" "" ""];

            tooltip-format = "{capacity}% | {time} | {power}W";
          };

          "group/group-power" = {
            orientation = "inherit";
            drawer = {
              transition-duration = 500;
              children-class = "not-power";
            };

            modules = ["custom/power" "custom/lock" "custom/reboot"];
          };

          "custom/power" = {
            format = "";
            tooltip = false;
            on-click = "shutdown now";
          };

          "custom/lock" = {
            format = "";
            tooltip = false;
            on-click = "swaylock";
          };

          "custom/reboot" = {
            format = "";
            tooltip = false;
            on-click = "reboot";
          };
        };
      };
    };
  };
}

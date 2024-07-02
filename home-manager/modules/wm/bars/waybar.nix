{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.bars.waybar;
in {
  options = {
    custom.wm.bars.waybar = {
      enable = lib.mkEnableOption "Enable waybar status bar";

      fonts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = map (font: "'${font.name}'") config.custom.applications.graphical.font.default;
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

        backlight = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable backlight support";
        };

        power-profiles = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable power profiles support";
        };

        media = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable media management via MPRIS";
        };

        tray = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable tray support";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [material-design-icons];

    services.playerctld = {
      enable = cfg.features.media;
    };

    programs.waybar = {
      enable = true;

      style = let
        bg-color = "#${config.colorScheme.palette.base00}";
        alt-bg-color = "#${config.colorScheme.palette.base01}";

        font-color = "#${config.colorScheme.palette.base05}";
        alt-font-color = "#${config.colorScheme.palette.base04}";

        focused-color = "#${config.colorScheme.palette.base0D}";

        status-color = "#${config.colorScheme.palette.base0B}";

        font-size = "${toString cfg.font-size}px";
      in ''
        * {
          border: none;
          border-radius: 0;
          font-family: ${lib.concatStringsSep ", " cfg.fonts}, 'Material Design Icons', monospace;
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

        #clock {
          border-bottom: 2px solid ${focused-color};
        }

        #privacy {
          background: ${status-color};
          border-radius: 25px;
          padding: 5px 10px;
          margin-right: 10px;
          margin-top: 5px;
          margin-bottom: 5px;
        }


        #status-modules, #mpris, #tray {
          background: ${alt-bg-color};
          padding: 0 5px;
          border-radius: 25px;
          margin-right: 5px;
          margin-top: 5px;
          margin-bottom: 5px;
        }

        #power-profiles-daemon, #backlight, #pulseaudio, #network, #battery, #custom-power, #custom-lock, #custom-reboot, #tray {
          font-size: 20px;
          padding: 0 10px;
        }
      '';

      settings = {
        main = {
          layer = "top";
          position = "top";

          height = 42;

          modules-left = lib.optional cfg.features.sway "sway/workspaces";
          modules-center = ["clock"];
          modules-right =
            lib.optional cfg.features.media "mpris"
            ++ ["privacy" "group/status-modules"]
            ++ lib.optional cfg.features.tray "tray";

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

          "mpris" = {
            format = "{player-icon}";
            format-paused = "{status_icon}";

            interval = 5;

            player-icons = {
              default = "󰐊";
              mpv = "󰝚";
              spotify = "󰓇";
            };
            status-icons = {
              paused = "󰏤";
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

          "group/status-modules" = {
            orientation = "inherit";
            modules =
              lib.optional cfg.features.power-profiles "power-profiles-daemon"
              ++ lib.optional cfg.features.backlight "backlight"
              ++ ["pulseaudio" "network"]
              ++ lib.optional cfg.features.battery "battery"
              ++ ["group/power-drawer"];
          };

          "power-profiles-daemon" = {
            format = "{icon}";
            tooltip-format = "Power profile: {profile}\nDriver: {driver}";
            format-icons = {
              default = "󱐋";
              performance = "󱐋";
              balanced = "󰗑";
              power-saver = "󰌪";
            };
          };

          "backlight" = {
            format = "{icon}";
            format-icons = ["󰃚" "󰃛" "󰃜" "󰃝" "󰃞" "󰃟" "󰃠"];

            tooltip-format = "{percent}%";
          };

          "pulseaudio" = {
            format = "{icon}";
            format-muted = "󰝟";
            format-icons = ["󰕿" "󰖀" "󰕾"];

            tooltip-format = "{volume}%";

            scroll-step = 5;

            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          };

          "network" = {
            interval = 5;

            format-ethernet = "󰈀";
            format-wifi = "{icon}";
            format-icons = ["󰤟" "󰤢" "󰤥" "󰤨"];
            format-disconnected = "󰪎";

            tooltip-format-ethernet = "{bandwidthUpBytes} up | {bandwidthDownBytes} down";
            tooltip-format-wifi = "{essid} | {bandwidthUpBytes} up | {bandwidthDownBytes} down";
            tooltip-format-disconnected = "Disconnected from the internet";
          };

          "battery" = {
            format = "{icon}";

            states = {
              warning = 20;
              critical = 5;
            };

            format-icons = ["󰂎" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰁹"];

            tooltip-format = "{capacity}% | {time} | {power}W";
          };

          "group/power-drawer" = {
            orientation = "inherit";
            drawer = {
              transition-left-to-right = false;
              transition-duration = 500;
            };

            modules = ["custom/power" "custom/lock" "custom/reboot"];
          };

          "custom/power" = {
            format = "󰐥";
            tooltip-format = "Shutdown";
            on-click = "shutdown now";
          };

          "custom/lock" = {
            format = "󰌾";
            tooltip-format = "Lock";
            on-click = "swaylock";
          };

          "custom/reboot" = {
            format = "󰜉";
            tooltip-format = "Reboot";
            on-click = "reboot";
          };
        };
      };
    };
  };
}

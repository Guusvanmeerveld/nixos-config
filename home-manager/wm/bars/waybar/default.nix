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

      font = lib.mkOption {
        type = lib.types.str;
        default = config.custom.programs.theming.font.serif.name;
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

        lockscreen = {
          enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable screen locking";
            default = true;
          };

          path = lib.mkOption {
            type = lib.types.str;
            description = "The path to the lock screen";
            default = config.custom.wm.lockscreens.default.path;
          };
        };

        wireguard = lib.mkEnableOption "Enable wireguard module";

        mconnect = lib.mkOption {
          type = lib.types.bool;
          default = config.custom.services.mconnect.enable;
          description = "Enable MConnect module";
        };

        swaync = lib.mkOption {
          type = lib.types.bool;
          description = "Enable support for swaync notification hub";
          default = config.custom.wm.notifications.swaync.enable;
        };

        tray = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable tray support";
        };

        hcfs = lib.mkEnableOption "Enable support for the HyperX Cloud Flight series of headsets";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [material-design-icons];

    services.playerctld = {
      enable = cfg.features.media;
    };

    # Configure bar in sway
    wayland.windowManager.sway.config.bars = [
      {
        command = lib.getExe pkgs.waybar;
      }
    ];

    programs.waybar = {
      enable = true;

      style = let
        bg-color = pkgs.custom.utils.makeTransparent "#${config.colorScheme.palette.base00}" 0.95;
        alt-bg-color = "#${config.colorScheme.palette.base01}";

        font-color = "#${config.colorScheme.palette.base06}";
        alt-font-color = "#${config.colorScheme.palette.base05}";

        focused-color = "#${config.colorScheme.palette.base0D}";

        status-color = "#${config.colorScheme.palette.base0B}";

        urgent-color = "#${config.colorScheme.palette.base08}";

        font-size = "${toString cfg.font-size}px";

        modules-spacing = 10;
      in ''
        * {
          border: none;
          border-radius: 0;
          font-family: '${cfg.font}', 'Material Design Icons', monospace;
          font-size: ${font-size};
        }

        window#waybar {
          background: ${bg-color};
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
          padding: 0 10px;
          color: ${font-color};
          border-bottom: 2px solid transparent;
        }

        #workspaces button.focused {
          background: ${alt-bg-color};
          color: ${alt-font-color};
          border-bottom: 2px solid ${focused-color};
        }

        #workspaces button.urgent {
          background: ${urgent-color};
          color: ${font-color};
          border-bottom: 2px solid transparent;
        }

        #clock {
          border-bottom: 2px solid ${focused-color};
        }

        #status-modules, #privacy, #mpris, #tray {
          background: ${alt-bg-color};
          padding: 0 5px;
          border-radius: 25px;
          margin-right: ${toString modules-spacing}px;
          margin-top: 5px;
          margin-bottom: 5px;
        }

        #privacy {
          background: ${status-color};
        }

        #power-profiles-daemon, #privacy, #mpris, #custom-hcfs, #custom-mconnect, #custom-wireguard, #backlight, #pulseaudio, #network, #battery, #custom-power, #custom-lock, #custom-logout, #custom-reboot, #custom-swaync, #tray {
          font-size: 20px;
          padding: 0 10px;
        }

        #mpris {
          font-size: ${font-size};
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
            format = "{player_icon} {title} - {artist}";
            format-paused = "{status_icon} {title} - {artist}";

            interval = 2;

            title-len = 24;

            player-icons = {
              default = "󰐊";
              mpv = "󰝚";
              spotify = "󰓇";
            };

            status-icons = {
              paused = "󰏦";
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
              lib.optional cfg.features.hcfs "custom/hcfs"
              ++ lib.optional cfg.features.mconnect "custom/mconnect"
              ++ lib.optional cfg.features.wireguard "custom/wireguard"
              ++ lib.optional cfg.features.power-profiles "power-profiles-daemon"
              ++ lib.optional cfg.features.backlight "backlight"
              ++ ["pulseaudio" "network"]
              ++ lib.optional cfg.features.battery "battery"
              ++ lib.optional cfg.features.swaync "custom/swaync"
              ++ ["group/power-drawer"];
          };

          "custom/mconnect" = lib.mkIf cfg.features.mconnect (let
            mconnectctl = "${pkgs.mconnect}/bin/mconnectctl";

            get-primary-device = "${mconnectctl} list-devices | head -2 | tail -1 | awk '{print $1}'";
            get-battery-level = "${mconnectctl} show-battery $(${get-primary-device}) | head -1 | awk '{print $2}'";
          in {
            exec = pkgs.writeShellScript "mconnect-waybar" ''
              BATTERY=$(${get-battery-level})
              INFO=$(${mconnectctl} show-device $(${get-primary-device}) | tail -8 | sed ':a;N;$!ba;s/\n/\\n/g')

              printf '{"percentage": %s, "text": "%s"}\n' "$BATTERY" "$INFO"
            '';

            return-type = "json";

            interval = 60;

            format = "{icon}";
            format-icons = ["󰤾" "󰤿" "󰥀" "󰥁" "󰥂" "󰥃" "󰥄" "󰥅" "󰥆" "󰥈"];

            tooltip-format = "Battery: {percentage}%\n{}";
          });

          "custom/wireguard" = lib.mkIf cfg.features.wireguard {
            format = "󰖂";
            tooltip = "{}";

            exec = "${./wireguard.sh} short";
            on-click = "${pkgs.rofi}/bin/rofi -modi 'WireGuard:${./wireguard-rofi.sh}' -show WireGuard; pkill -SIGRTMIN+6 waybar";
            return-type = "json";

            signal = 6;
            interval = 60;
          };

          "custom/hcfs" = lib.mkIf cfg.features.hcfs {
            tooltip = "{}";

            format = "󰋎 {icon}";
            format-icons = ["󰤾" "󰤿" "󰥀" "󰥁" "󰥂" "󰥃" "󰥄" "󰥅" "󰥆" "󰥈"];

            exec = lib.getExe (pkgs.writeShellApplication {
              name = "hcfs-waybar";

              runtimeInputs = with pkgs; [jq hyperx-cloud-flight-s];

              text = ''
                hcfs daemon | jq --unbuffered --compact-output '{ percentage: .battery }'
              '';
            });

            return-type = "json";
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

            on-click = lib.getExe pkgs.pavucontrol;
          };

          "network" = {
            interval = 5;

            on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";

            format-ethernet = "󰈀";
            format-wifi = "{icon}";
            format-icons = ["󰤟" "󰤢" "󰤥" "󰤨"];
            format-disconnected = "󰪎";

            tooltip-format-ethernet = "{bandwidthUpBytes} up | {bandwidthDownBytes} down";
            tooltip-format-wifi = "{essid} | {bandwidthUpBytes} up | {bandwidthDownBytes} down";
            tooltip-format-disconnected = "Disconnected from the internet";
          };

          "battery" = let
            default-tooltip = "{capacity}% | {time} | {power}W";
          in {
            format = "{icon}";

            interval = 5;

            format-charging = "󰂄";

            states = {
              warning = 20;
              critical = 5;
            };

            format-icons = ["󰂎" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰁹"];

            tooltip-format-charging = "Charging | ${default-tooltip}";
            tooltip-format = default-tooltip;
          };

          "custom/swaync" = lib.mkIf cfg.features.swaync (let
            inherit (config.services.swaync) package;
            swaync-client = "${package}/bin/swaync-client";
          in {
            format = "{icon}";

            format-icons = {
              notification = "󰂚<span foreground='red'><sup></sup></span>";
              none = "󰂚";

              dnd-notification = "󰂛<span foreground='red'><sup></sup></span>";
              dnd-none = "󰂛";

              inhibited-notification = "󰂚<span foreground='red'><sup></sup></span>";
              inhibited-none = "󰂚";

              dnd-inhibited-notification = "󰂛<span foreground='red'><sup></sup></span>";
              dnd-inhibited-none = "󰂛";
            };

            tooltip-format = "{} notification(s)";

            return-type = "json";
            exec = "${swaync-client} -swb";
            on-click = "${swaync-client} -t -sw";
            on-click-right = "${swaync-client} -d -sw";

            escape = true;
          });

          "group/power-drawer" = {
            orientation = "inherit";
            drawer = {
              transition-left-to-right = false;
              transition-duration = 500;
            };

            modules = ["custom/power" "custom/logout"] ++ lib.optional cfg.features.lockscreen.enable "custom/lock" ++ ["custom/reboot"];
          };

          "custom/power" = {
            format = "󰐥";
            tooltip-format = "Shutdown";
            on-click = "shutdown now";
          };

          "custom/lock" = {
            format = "󰌾";
            tooltip-format = "Lock";
            on-click = cfg.features.lockscreen.path;
          };

          "custom/logout" = {
            format = "󰍃";
            tooltip-format = "Logout";
            on-click = "swaymsg exit";
          };

          "custom/reboot" = {
            format = "󰜉";
            tooltip-format = "Reboot";
            on-click = "reboot";
          };

          "tray" = {
            icon-size = 20;
            spacing = 10;
          };
        };
      };
    };
  };
}

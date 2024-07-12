{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.wayland.sway;
  workspaces = [1 2 3 4 5 6 7 8 9];
  gapSize = 5;

  playerctl = "${pkgs.playerctl}/bin/playerctl";
in {
  options = {
    custom.wm.wayland.sway = {
      enable = lib.mkEnableOption "Enable sway window manager";

      modifierKey = lib.mkOption {
        type = lib.types.str;
        default = "Mod4"; # Super / Windows key
        description = "The main key for all key combinations";
      };

      terminal = lib.mkOption {
        type = lib.types.str;
        default = config.custom.applications.graphical.defaultApplications.terminal.path;
        description = "The default terminal to use";
      };

      menu = lib.mkOption {
        type = lib.types.str;
        default = config.custom.applications.graphical.defaultApplications.menu.path;
        description = "The default menu application to use";
      };

      file-explorer = lib.mkOption {
        type = lib.types.str;
        default = config.custom.applications.graphical.defaultApplications.file-explorer.path;
        description = "The default file explorer to use";
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

      notification = {
        enable = lib.mkOption {
          type = lib.types.bool;
          description = "Enable notification service";
          default = true;
        };

        path = lib.mkOption {
          type = lib.types.str;
          description = "The path to the notification service";
          default = config.custom.wm.notifications.default.path;
        };
      };

      keybinds = {
        screenshot = {
          enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable screenshot functionality";
            default = true;
          };

          path = lib.mkOption {
            type = lib.types.str;
            description = "Path to screenshot program";
            default = config.custom.applications.graphical.defaultApplications.screenshot.path;
          };
        };

        media = lib.mkOption {
          type = lib.types.bool;
          description = "Enable media hotkey configuration";
          default = true;
        };

        backlight = lib.mkOption {
          type = lib.types.bool;
          description = "Enable backlight hotkey configuration";
          default = false;
        };

        sound = lib.mkOption {
          type = lib.types.bool;
          description = "Enable sound hotkey configuration";
          default = true;
        };
      };

      output = lib.mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
        default = {};
        description = ''
          Attribute set that defines outputs. See {manpage} sway-input(5) for details
        '';
      };

      input = lib.mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
        default = {};
        description = ''
          An attribute set that defines inputs. See {manpage}`sway-input(5)` for details.
        '';
      };

      fonts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = map (font: font.name) config.custom.applications.graphical.font.default;
        description = "The font to use for displaying title bar text";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.default = {
      name = "sway";
      path = "${pkgs.sway}/bin/sway";
    };

    services.playerctld = {
      enable = lib.mkDefault cfg.keybinds.media;
    };

    # home.packages =
    #   lib.optional cfg.keybinds.media pkgs.playerctl
    #   ++ lib.optional cfg.keybinds.backlight pkgs.light
    #   ++ lib.optional cfg.keybinds.sound pkgs.pulseaudio;

    wayland.windowManager.sway = {
      enable = true;

      wrapperFeatures = {
        gtk = true;
      };

      extraConfig = ''
        title_align center
      '';

      config = rec {
        inherit (cfg) output;

        input =
          cfg.input
          // {
            "type:touchpad" = {
              natural_scroll = "enabled";
              tap = "enabled";
            };
          };

        modifier = cfg.modifierKey;
        terminal = cfg.terminal;
        menu = cfg.menu;

        window.border = 0;

        left = "h";
        up = "k";
        right = "l";
        down = "j";

        fonts = {
          names = cfg.fonts;
          size = 12.0;
        };

        gaps = {
          top = gapSize;
          bottom = gapSize;
          left = gapSize;
          right = gapSize;
          inner = gapSize;
          outer = gapSize;
        };

        colors = let
          bg-color = "#${config.colorScheme.palette.base00}";
          alt-bg-color = "#${config.colorScheme.palette.base01}";

          font-color = "#${config.colorScheme.palette.base05}";
          alt-font-color = "#${config.colorScheme.palette.base04}";

          urgent-color = "#${config.colorScheme.palette.base08}";
        in {
          background = bg-color;

          focused = {
            background = alt-bg-color;
            border = alt-bg-color;
            childBorder = alt-bg-color;
            indicator = alt-bg-color;
            text = alt-font-color;
          };

          focusedInactive = {
            background = alt-bg-color;
            border = alt-bg-color;
            childBorder = alt-bg-color;
            indicator = alt-bg-color;
            text = alt-font-color;
          };

          unfocused = {
            background = bg-color;
            border = bg-color;
            childBorder = bg-color;
            indicator = bg-color;
            text = font-color;
          };

          urgent = {
            background = urgent-color;
            border = urgent-color;
            childBorder = urgent-color;
            indicator = urgent-color;
            text = font-color;
          };
        };

        bars = [
          {
            command = "${pkgs.waybar}/bin/waybar";
          }
        ];

        startup =
          [
            (let
              sway-idle = "${pkgs.swayidle}/bin/swayidle";
              systemctl = "${pkgs.systemd}/bin/systemctl";

              lockscreen-timeout = 300;
              suspend-timeout = lockscreen-timeout + 30;

              lockscreen-cfg = lib.optionalString cfg.lockscreen.enable "timeout ${toString lockscreen-timeout} '${cfg.lockscreen.path}' \\";

              command = pkgs.writeShellScript "run-sway-idle" ''
                ${sway-idle} -w \
                  ${lockscreen-cfg}
                  timeout ${toString suspend-timeout} '${systemctl} suspend'
              '';
            in {
              command = toString command;
            })
          ]
          ++ lib.optional cfg.notification.enable {
            command = cfg.notification.path;
          };

        keycodebindings = {
          # XF86AudioPlayPause: xmodmap -pke | grep XF86AudioPlay
          # https://github.com/swaywm/sway/issues/4783
          "172" = lib.mkIf cfg.keybinds.media "exec ${playerctl} play-pause";
        };

        keybindings =
          {
            # Directional focus
            "${modifier}+${left}" = "focus left";
            "${modifier}+${up}" = "focus up";
            "${modifier}+${right}" = "focus right";
            "${modifier}+${down}" = "focus down";

            # Directional move
            "${modifier}+Shift+${left}" = "move left";
            "${modifier}+Shift+${up}" = "move up";
            "${modifier}+Shift+${right}" = "move right";
            "${modifier}+Shift+${down}" = "move down";

            "${modifier}+b" = "splith";
            "${modifier}+v" = "splitv";

            "${modifier}+Shift+c" = "reload";

            # Essential applications
            "${modifier}+Return" = "exec ${terminal}";
            "${modifier}+space" = "exec ${menu}";

            # Modify container
            "${modifier}+w" = "kill";
            "${modifier}+s" = "floating toggle";
            "${modifier}+f" = "fullscreen toggle";

            # File explorer shortcut
            "${modifier}+e" = "exec ${cfg.file-explorer}";

            "Print" = lib.mkIf cfg.keybinds.screenshot.enable "exec ${cfg.keybinds.screenshot.path}";
          }
          # Workspace switchers
          // builtins.listToAttrs (map (value: {
              name = "${modifier}+${toString value}";
              value = "workspace number ${toString value}";
            })
            workspaces)
          # Move container to workspace
          // builtins.listToAttrs (map (value: {
              name = "${modifier}+Shift+${toString value}";
              value = "move container to workspace number ${toString value}";
            })
            workspaces)
          // lib.optionalAttrs cfg.lockscreen.enable {
            # "XF86WakeUp" = "exec ${cfg.lockscreen.path}";
            "${modifier}+0" = "exec ${cfg.lockscreen.path}";
          }
          # Audio control keybinds
          // lib.optionalAttrs cfg.keybinds.sound (let
            pactl = "${pkgs.pulseaudio}/bin/pactl";
          in {
            "XF86AudioLowerVolume" = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ -5%";
            "XF86AudioRaiseVolume" = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ +5%";
          })
          # Screen backlight keybinds
          // lib.optionalAttrs cfg.keybinds.backlight (let
            light = "${pkgs.light}/bin/light";
          in {
            "XF86MonBrightnessUp" = "exec ${light} -A 5";
            "XF86MonBrightnessDown" = "exec ${light} -U 5";
          })
          # Media keybinds
          // lib.optionalAttrs cfg.keybinds.media {
            "XF86AudioPlay" = "exec ${playerctl} play";
            "XF86AudioStop" = "exec ${playerctl} pause";
            "XF86AudioPause" = "exec ${playerctl} play-pause";
            # "XF86AudioPlayPause" = "exec ${playerctl} play-pause";
            "XF86AudioNext" = "exec ${playerctl} next";
            "XF86AudioPrev" = "exec ${playerctl} previous";
          };
      };
    };
  };
}

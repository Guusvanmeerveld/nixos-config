{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.wayland.sway;
  workspaces = lib.range 1 9;
  gapSize = 5;

  swayosd-client = "${pkgs.swayosd}/bin/swayosd-client";

  package =
    if cfg.useFx
    then pkgs.swayfx
    else pkgs.sway;

  playerctl = "${pkgs.playerctl}/bin/playerctl";

  lockscreen-timeout = 300;
  screenoff-timeout = lockscreen-timeout + 60;
  suspend-timeout = screenoff-timeout + 300;

  lockscreen-cfg = lib.optionalString cfg.lockscreen.enable "timeout ${toString lockscreen-timeout} '${cfg.lockscreen.path}' \\";

  idle-manager = pkgs.writeShellApplication {
    name = "run-sway-idle";

    runtimeInputs = (with pkgs; [swayidle systemd]) ++ [package];

    text = ''
      swayidle -w \
        ${lockscreen-cfg}
        timeout ${toString screenoff-timeout} 'swaymsg "output * dpms off"' \
        resume 'swaymsg "output * dpms on"' \
        timeout ${toString suspend-timeout} 'systemctl suspend'
    '';
  };
in {
  imports = [./osd.nix];

  options = {
    custom.wm.wayland.sway = {
      enable = lib.mkEnableOption "Enable sway window manager";

      useFx = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use swayfx instead of normal sway";
      };

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
          default = false;
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

        osd = lib.mkOption {
          type = lib.types.bool;
          description = "Enable osd for brightness and volume controls";
          default = config.custom.wm.wayland.sway.osd.enable;
        };

        gsr = lib.mkOption {
          type = lib.types.bool;
          description = "Enable GSR replay saving keybind";
          default = config.custom.applications.services.gpu-screen-recorder.enable;
        };

        cliphist = lib.mkOption {
          type = lib.types.bool;
          description = "Enable Cliphist clipboard history menu";
          default = config.custom.wm.wayland.cliphist.enable;
        };

        # custom = lib.mkOption {
        #   type = lib.types.attrsOf lib.types.str;
        #   description = "Custom keybinds";
        #   default = {};
        # };
      };

      startup = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            path = lib.mkOption {
              type = lib.types.str;
              description = "Path to executable";
            };

            runOnRestart = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
          };
        });

        default = [];
        description = ''
          Applications to run at startup
        '';
      };

      output = lib.mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
        default = {};
        description = ''
          Attribute set that defines outputs. See {manpage} sway-input(5) for details
        '';
      };

      workspaceOutputAssign = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            output = lib.mkOption {
              type = lib.types.str;
            };

            workspaces = lib.mkOption {
              type = lib.types.listOf lib.types.int;
            };
          };
        });
        default = [];
        description = ''
          Assign workspaces to outputs.
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
        default = map (font: font.name) config.custom.applications.graphical.theming.font.default;
        description = "The font to use for displaying title bar text";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.default = {
      name = "sway";
      path = "${package}/bin/sway";
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

      package = package;

      # Required to use the current nixpkgs version of swayfx.
      # See https://github.com/nix-community/home-manager/issues/5379
      checkConfig = false;

      wrapperFeatures = {
        gtk = true;
      };

      extraConfig = ''
        title_align center

        corner_radius 15
      '';

      config = rec {
        inherit (cfg) output;

        workspaceOutputAssign = lib.flatten (map (assignment: (map (workspace: {
            workspace = toString workspace;
            output = assignment.output;
          })
          assignment.workspaces))
        cfg.workspaceOutputAssign);

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

        window = {
          border = 0;
          titlebar = false;

          # Prevent idle when fullscreen app is shown
          commands = [
            {
              criteria = {
                class = "^.*";
              };
              command = "inhibit_idle fullscreen";
            }
            {
              criteria = {
                app_id = "^.*";
              };
              command = "inhibit_idle fullscreen";
            }

            # Show XWayland windows
            {
              criteria = {
                shell = "xwayland";
              };
              command = ''title_format "[XWayland] %title"'';
            }
          ];
        };

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
          # Manage monitor on idle
          lib.singleton {
            command = lib.getExe idle-manager;
          }
          # Notification daemon
          ++ lib.optional cfg.notification.enable {
            command = cfg.notification.path;
          }
          # Custom startup commands
          ++ map (command: {
            command = command.path;
            always = command.runOnRestart;
          })
          cfg.startup;

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

            "${modifier}+p" = lib.mkIf cfg.keybinds.gsr "exec gsr-save-replay";

            "Ctrl+Alt+v" = lib.mkIf cfg.keybinds.cliphist "exec cliphist-menu";

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

            raise-command =
              if cfg.keybinds.osd
              then "${swayosd-client} --output-volume +5"
              else "${pactl} set-sink-volume @DEFAULT_SINK@ +5%";

            lower-command =
              if cfg.keybinds.osd
              then "${swayosd-client} --output-volume -5"
              else "${pactl} set-sink-volume @DEFAULT_SINK@ -5%";

            mute-command =
              if cfg.keybinds.osd
              then "${swayosd-client} --output-volume mute-toggle"
              else "";

            mic-mute-command =
              if cfg.keybinds.osd
              then "${swayosd-client} --input-volume mute-toggle"
              else "";
          in {
            "XF86AudioRaiseVolume" = "exec ${raise-command}";
            "XF86AudioLowerVolume" = "exec ${lower-command}";

            "XF86AudioMute" = "exec ${mute-command}";
            "XF86AudioMicMute" = "exec ${mic-mute-command}";
          })
          # Screen backlight keybinds
          // lib.optionalAttrs cfg.keybinds.backlight (let
            light = "${pkgs.light}/bin/light";

            up-command =
              if cfg.keybinds.osd
              then "${swayosd-client} --brightness +5"
              else "${light} -A 5";

            down-command =
              if cfg.keybinds.osd
              then "${swayosd-client} --brightness -5"
              else "${light} -U 5";
          in {
            "XF86MonBrightnessUp" = "exec ${up-command}";
            "XF86MonBrightnessDown" = "exec ${down-command}";
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

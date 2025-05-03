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
        default = config.custom.programs.defaultApplications.terminal.path;
        description = "The default terminal to use";
      };

      menu = lib.mkOption {
        type = lib.types.str;
        default = config.custom.programs.defaultApplications.menu.path;
        description = "The default menu application to use";
      };

      file-explorer = lib.mkOption {
        type = lib.types.str;
        default = config.custom.programs.defaultApplications.file-explorer.path;
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
            default = config.custom.programs.defaultApplications.screenshot.path;
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

        wlsr = lib.mkOption {
          type = lib.types.bool;
          description = "Enable WLSR replay saving keybind";
          # default = config.services.wl-screenrec.enable;
          default = false;
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

      font = lib.mkOption {
        type = lib.types.str;
        default = config.custom.programs.theming.font.serif.name;
        description = "The font to use for displaying title bar text";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.default = {
      name = "sway";
      path = "${package}/bin/sway";
    };

    home.packages = with pkgs; [wdisplays];

    services.playerctld = {
      enable = lib.mkDefault cfg.keybinds.media;
    };

    wayland.windowManager.sway = {
      enable = true;

      inherit package;

      systemd.xdgAutostart = true;

      # Required to use the current nixpkgs version of swayfx.
      # See https://github.com/nix-community/home-manager/issues/5379
      checkConfig = lib.mkDefault (!cfg.useFx);

      wrapperFeatures = {
        gtk = true;
      };

      extraConfig = ''
        title_align center

        ${lib.optionalString cfg.useFx ''
          corner_radius 7
          blur enable
        ''}
      '';

      config = rec {
        inherit (cfg) output;

        workspaceOutputAssign = lib.flatten (map (assignment: (map (workspace: {
            workspace = toString workspace;
            inherit (assignment) output;
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
        inherit (cfg) terminal;
        inherit (cfg) menu;

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
          names = [cfg.font];
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

        modes = {
          present = let
            wl-present = "${pkgs.wl-mirror}/bin/wl-present";
          in {
            # command starts mirroring
            m = ''mode "default"; exec ${wl-present} mirror'';
            # these commands modify an already running mirroring window
            o = ''mode "default"; exec ${wl-present} set-output'';
            r = ''mode "default"; exec ${wl-present} set-region'';
            "Shift+r" = ''mode "default"; exec ${wl-present} unset-region'';
            s = ''mode "default"; exec ${wl-present} set-scaling'';
            f = ''mode "default"; exec ${wl-present} toggle-freeze'';
            c = ''mode "default"; exec ${wl-present} custom'';

            # return to default mode
            Return = ''mode "default"'';
            Escape = ''mode "default"'';
          };
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

            "${modifier}+i" = "splith";
            "${modifier}+o" = "splitv";

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

            "${modifier}+u" = lib.mkIf cfg.keybinds.wlsr "exec wlsr-save-replay";

            "Ctrl+Alt+v" = lib.mkIf cfg.keybinds.cliphist "exec cliphist-menu";

            "Print" = lib.mkIf cfg.keybinds.screenshot.enable "exec ${cfg.keybinds.screenshot.path}";

            # Allow switching to present mode
            "${modifier}+p " = ''mode "present"'';
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

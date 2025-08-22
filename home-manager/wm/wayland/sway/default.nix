{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.wayland.sway;
  workspaces = lib.range 1 9;
  gapSize = 5;

  package =
    if cfg.useSwayFx
    then pkgs.swayfx
    else pkgs.sway;
in {
  imports = [./osd.nix ./idle.nix];

  options = {
    custom.wm.wayland.sway = {
      enable = lib.mkEnableOption "Enable sway window manager";

      useSwayFx = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use swayFx instead of normal sway";
      };

      modifierKey = lib.mkOption {
        type = lib.types.str;
        default = "Mod4"; # Super / Windows key
        description = "The main key for all key combinations";
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
    wayland = {
      systemd.target = "sway-session.target";

      windowManager.sway = {
        enable = true;

        inherit package;

        systemd = {
          xdgAutostart = true;

          extraCommands = [
            "systemctl --user import-environment PATH"
            "systemctl --user restart xdg-desktop-portal.service"
            "systemctl --user reset-failed"
            "systemctl --user start sway-session.target"
            "swaymsg -mt subscribe '[]' || true"
            "systemctl --user stop sway-session.target"
          ];
        };

        # Required to use the current nixpkgs version of swayfx.
        # See https://github.com/nix-community/home-manager/issues/5379
        checkConfig = lib.mkDefault (!cfg.useSwayFx);

        wrapperFeatures = {
          gtk = true;
        };

        extraConfigEarly = ''
          set $mod ${cfg.modifierKey}
        '';

        extraConfig = ''
          title_align center

          ${lib.optionalString cfg.useSwayFx ''
            corner_radius 7
            blur enable
            default_dim_inactive 0.1
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

              "*" = {
                xkb_options = "compose:rctrl";
              };
            };

          modifier = cfg.modifierKey;

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

          keybindings = lib.mkMerge [
            (let
              pactl = lib.getExe' pkgs.pulseaudio "pactl";
              light = lib.getExe pkgs.light;
              playerctl = lib.getExe pkgs.playerctl;
            in {
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

              # Modify container
              "${modifier}+w" = "kill";
              "${modifier}+s" = "floating toggle";
              "${modifier}+f" = "fullscreen toggle";

              # Allow switching to present mode
              "${modifier}+p " = ''mode "present"'';

              # Audio control keybinds
              "XF86AudioRaiseVolume" = lib.mkDefault "exec ${pactl} set-sink-volume @DEFAULT_SINK@ +5%";
              "XF86AudioLowerVolume" = lib.mkDefault "exec ${pactl} set-sink-volume @DEFAULT_SINK@ -5%";

              "XF86AudioMute" = lib.mkDefault "exec ${pactl} set-sink-mute @DEFAULT_SINK@ true";
              "XF86AudioMicMute" = lib.mkDefault "exec ${pactl} set-source-mute @DEFAULT_SOURCE@ true";

              # Screen backlight keybinds
              "XF86MonBrightnessUp" = lib.mkDefault "exec ${light} -A 5";
              "XF86MonBrightnessDown" = lib.mkDefault "exec ${light} -U 5";

              # Music playback keybinds
              "XF86AudioPlay" = lib.mkDefault "exec ${playerctl} play";
              "XF86AudioStop" = lib.mkDefault "exec ${playerctl} pause";
              "XF86AudioPause" = lib.mkDefault "exec ${playerctl} play-pause";
              "XF86AudioNext" = lib.mkDefault "exec ${playerctl} next";
              "XF86AudioPrev" = lib.mkDefault "exec ${playerctl} previous";

              ${config.custom.wm.lockscreens.default.keybind} = "exec ${config.custom.wm.lockscreens.default.executable}";
            })

            # Workspace switchers
            (builtins.listToAttrs
              (map (value: {
                  name = "${modifier}+${toString value}";
                  value = "workspace number ${toString value}";
                })
                workspaces))

            # Move container to workspace
            (builtins.listToAttrs (map (value: {
                name = "${modifier}+Shift+${toString value}";
                value = "move container to workspace number ${toString value}";
              })
              workspaces))

            (
              lib.listToAttrs (map ({
                  appId,
                  keybind,
                  executable,
                  ...
                }: let
                  # If we are given an app id, we want to be able to focus an existing window using the keybind.
                  runnable =
                    if appId != null
                    then
                      # If we cannot focus the window, start it.
                      pkgs.writeShellScript "sway-focus-or-start-${appId}" ''
                        if ! swaymsg [app_id="${appId}"] focus; then
                          exec ${executable};
                        fi
                      ''
                    else executable;
                in {
                  name = keybind;
                  value = "exec ${runnable}";
                }) (builtins.filter (application:
                  application.keybind != null)
                config.custom.wm.applications))
            )
          ];

          bars =
            map (
              bar: {
                command = bar.executable;
              }
            )
            config.custom.wm.bars.bars;

          assigns = lib.mapAttrs (_workspace: applications:
            map ({appId, ...}: {
              app_id = "^${appId}$";
            })
            applications) (builtins.groupBy (application: toString application.workspace) (builtins.filter (application:
            application.workspace != null && application.appId != null)
          config.custom.wm.applications));
        };
      };
    };
  };
}

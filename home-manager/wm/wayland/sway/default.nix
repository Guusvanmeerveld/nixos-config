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
    if cfg.useSwayFx
    then pkgs.swayfx
    else pkgs.sway;

  lockscreen-timeout = 300;
  screenoff-timeout = lockscreen-timeout + 60;
  suspend-timeout = screenoff-timeout + 300;

  lockscreen-cfg = "timeout ${toString lockscreen-timeout} '${config.custom.wm.lockscreens.default.executable}' \\";

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

      keybinds = {
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

          startup =
            # Manage monitor on idle
            lib.singleton {
              command = lib.getExe idle-manager;
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

              # Modify container
              "${modifier}+w" = "kill";
              "${modifier}+s" = "floating toggle";
              "${modifier}+f" = "fullscreen toggle";

              "${modifier}+u" = lib.mkIf cfg.keybinds.wlsr "exec wlsr-save-replay";

              # Allow switching to present mode
              "${modifier}+p " = ''mode "present"'';
            }

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

            # Audio control keybinds
            (
              lib.optionalAttrs cfg.keybinds.sound (let
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
            )

            # Screen backlight keybinds
            (
              lib.optionalAttrs cfg.keybinds.backlight (let
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
            )

            (
              lib.listToAttrs (map (application: {
                  name = application.keybind;
                  value = "exec ${application.executable}";
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

          assigns = lib.listToAttrs (map (application: {
              name = toString application.workspace;
              value = [
                {
                  app_id = "^${application.appId}$";
                }
              ];
            }) (builtins.filter (application:
              application.workspace != null && application.appId != null)
            config.custom.wm.applications));
        };
      };
    };
  };
}

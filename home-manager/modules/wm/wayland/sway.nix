{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.wayland.sway;
  workspaces = [1 2 3 4 5 6 7 8 9];
  gapSize = 5;
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

      enableMediaHotkeys = lib.mkOption {
        type = lib.types.bool;
        description = "Enable media hotkey configuration";
        default = true;
      };

      output = lib.mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
        default = {};
        description = "Attribute set that defines outputs. See {manpage} sway-input(5) for details";
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
      enable = cfg.enableMediaHotkeys;
    };

    home.packages = lib.optional cfg.enableMediaHotkeys pkgs.playerctl;

    wayland.windowManager.sway = {
      enable = true;

      wrapperFeatures = {
        gtk = true;
      };

      config = rec {
        modifier = cfg.modifierKey;
        terminal = cfg.terminal;
        menu = cfg.menu;

        output = cfg.output;

        left = "h";
        up = "k";
        right = "l";
        down = "j";

        fonts = {
          names = cfg.fonts;
          size = 12.0;
        };

        # input = {
        # };

        gaps = {
          top = gapSize;
          bottom = gapSize;
          left = gapSize;
          right = gapSize;
          inner = gapSize;
          outer = gapSize;
        };

        colors = {
          background = "#${config.colorScheme.palette.base00}";

          focused = {
            background = "#${config.colorScheme.palette.base01}";
            border = "#${config.colorScheme.palette.base01}";
            childBorder = "#${config.colorScheme.palette.base01}";
            indicator = "#${config.colorScheme.palette.base01}";
            text = "#${config.colorScheme.palette.base04}";
          };

          unfocused = {
            background = "#${config.colorScheme.palette.base00}";
            border = "#${config.colorScheme.palette.base00}";
            childBorder = "#${config.colorScheme.palette.base00}";
            indicator = "#${config.colorScheme.palette.base00}";
            text = "#${config.colorScheme.palette.base05}";
          };

          urgent = {
            background = "#${config.colorScheme.palette.base08}";
            border = "#${config.colorScheme.palette.base08}";
            childBorder = "#${config.colorScheme.palette.base08}";
            indicator = "#${config.colorScheme.palette.base08}";
            text = "#${config.colorScheme.palette.base05}";
          };
        };

        bars = [
          {
            command = "${pkgs.waybar}/bin/waybar";
          }
        ];

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

            "${modifier}+s" = "floating toggle";

            "${modifier}+Shift+c" = "reload";

            # Essential applications
            "${modifier}+Return" = "exec ${terminal}";
            "${modifier}+space" = "exec ${menu}";

            # Modify container
            "${modifier}+w" = "kill";
            "${modifier}+f" = "fullscreen toggle";

            # File explorer shortcut
            "${modifier}+e" = "exec ${cfg.file-explorer}";

            "Print" = lib.mkIf cfg.screenshot.enable "exec ${cfg.screenshot.path}";

            "XF86AudioPlay" = lib.mkIf cfg.enableMediaHotkeys "exec ${pkgs.playerctl}/bin/playerctl play";
            "XF86AudioStop" = lib.mkIf cfg.enableMediaHotkeys "exec ${pkgs.playerctl}/bin/playerctl pause";
            "XF86AudioPause" = lib.mkIf cfg.enableMediaHotkeys "exec ${pkgs.playerctl}/bin/playerctl play-pause";
            "XF86AudioNext" = lib.mkIf cfg.enableMediaHotkeys "exec ${pkgs.playerctl}/bin/playerctl next";
            "XF86AudioPrev" = lib.mkIf cfg.enableMediaHotkeys "exec ${pkgs.playerctl}/bin/playerctl previous";
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
            workspaces);
      };
    };
  };
}

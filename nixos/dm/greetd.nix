{
  shared,
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.dm.greetd;

  regreet = lib.getExe pkgs.greetd.regreet;

  swayConfig = pkgs.writeText "greetd-sway-config" ''
    exec "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP XDG_SESSION_TYPE NIXOS_OZONE_WL XCURSOR_THEME XCURSOR_SIZE"

    exec "${regreet}; swaymsg exit"

    bindsym Mod4+shift+e exec swaynag \
      -t warning \
      -m 'What do you want to do?' \
      -b 'Poweroff' 'systemctl poweroff' \
      -b 'Reboot' 'systemctl reboot'

    input "type:pointer" {
      accel_profile flat
      pointer_accel -0.25
    }

    ${
      lib.concatStringsSep "\n" (
        map ({
          name,
          value,
        }: ''
          output ${name} {
            mode ${value.resolution}@${toString value.refreshRate}Hz
            bg ${value.background}
            pos ${toString value.position.x} ${toString value.position.y}
            transform ${toString value.transform}
          }
        '')
        (lib.attrsToList cfg.outputs)
      )
    }
  '';

  sway = "${lib.getExe pkgs.sway} --config ${swayConfig}";
in {
  options = {
    custom.dm.greetd = {
      enable = lib.mkEnableOption "Enable greetd display manager";

      outputs = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            resolution = lib.mkOption {
              type = lib.types.str;
              default = "1920x1080";
            };

            refreshRate = lib.mkOption {
              type = lib.types.float;
              default = 60;
            };

            background = lib.mkOption {
              type = lib.types.str;
            };

            transform = lib.mkOption {
              type = lib.types.int;
              default = 0;
            };

            position = {
              x = lib.mkOption {
                type = lib.types.int;
                default = 0;
              };

              y = lib.mkOption {
                type = lib.types.int;
                default = 0;
              };
            };
          };
        });

        description = "A list of the monitors currently connected to the system";

        example = {
          "HDMI-A-1" = {
            resolution = "2560x1440";
            refreshRate = 74.968;
            transform = 90;
            background = "${./monitor.jpg} stretch";
            position = {
              x = 0;
              y = 0;
            };
          };
        };
        default = {};
      };

      gtk = let
        defaultThemingOptions = shared.theming;
      in {
        font = {
          package = lib.mkPackageOption pkgs defaultThemingOptions.font.serif.package {};

          name = lib.mkOption {
            type = lib.types.str;
            description = "The fonts name";

            default = defaultThemingOptions.font.serif.name;
          };
        };

        theme = {
          name = lib.mkOption {
            type = lib.types.str;
            default = defaultThemingOptions.gtk.theme.name;
          };

          package = lib.mkPackageOption pkgs defaultThemingOptions.gtk.theme.package {};
        };

        iconTheme = {
          name = lib.mkOption {
            type = lib.types.str;
            default = defaultThemingOptions.gtk.iconTheme.name;
          };

          package = lib.mkPackageOption pkgs defaultThemingOptions.gtk.iconTheme.package {};
        };

        cursorTheme = {
          name = lib.mkOption {
            type = lib.types.str;
            default = defaultThemingOptions.cursor.name;
          };

          package = lib.mkPackageOption pkgs defaultThemingOptions.cursor.package {};
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    allowedUnfree = ["apple_cursor"];

    programs.regreet = {
      enable = true;

      cursorTheme = cfg.gtk.cursorTheme;
      iconTheme = cfg.gtk.iconTheme;
      theme = cfg.gtk.theme;
      font = lib.mkMerge [
        cfg.gtk.font
        {
          size = 14;
        }
      ];
    };

    services.greetd = {
      enable = true;

      settings = {
        default_session = {
          command = sway;
        };
      };
    };
  };
}

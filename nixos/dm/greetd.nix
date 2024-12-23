{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.dm.greetd;
  outputsCfg = config.custom.hardware.video.outputs;

  defaultEnvironment = config.custom.wm.default.path;

  regreet = lib.getExe pkgs.greetd.regreet;

  swayConfig = pkgs.writeText "greetd-sway-config" ''
    exec "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP XDG_SESSION_TYPE NIXOS_OZONE_WL XCURSOR_THEME XCURSOR_SIZE"

    exec "${regreet}; swaymsg exit"

    bindsym Mod4+shift+e exec swaynag \
      -t warning \
      -m 'What do you want to do?' \
      -b 'Poweroff' 'systemctl poweroff' \
      -b 'Reboot' 'systemctl reboot'

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
        (lib.attrsToList outputsCfg)
      )
    }
  '';

  sway = "${lib.getExe pkgs.sway} --config ${swayConfig}";
in {
  options = {
    custom.dm.greetd = {
      enable = lib.mkEnableOption "Enable greetd display manager";

      tuigreet = {
        enable = lib.mkEnableOption "Enable tuigreet";
      };

      gtk = {
        font = {
          package = lib.mkPackageOption pkgs "inter" {};

          name = lib.mkOption {
            type = lib.types.str;
            description = "The fonts name";

            default = "Inter";
          };
        };

        theme = {
          name = lib.mkOption {
            type = lib.types.str;
            default = "WhiteSur-Dark";
          };

          package = lib.mkPackageOption pkgs "whitesur-gtk-theme" {};
        };

        iconTheme = {
          name = lib.mkOption {
            type = lib.types.str;
            default = "WhiteSur-dark";
          };

          package = lib.mkPackageOption pkgs "whitesur-icon-theme" {};
        };

        cursorTheme = {
          name = lib.mkOption {
            type = lib.types.str;
            default = "macOS-BigSur";
          };

          package = lib.mkPackageOption pkgs "apple-cursor" {};
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.regreet = {
      enable = true;

      # cursorTheme = cfg.gtk.cursorTheme;
      # iconTheme = cfg.gtk.iconTheme;
      # theme = cfg.gtk.theme;
      # font = cfg.gtk.font;
    };

    services.greetd = {
      enable = true;

      settings = {
        default_session = {
          command = sway;
        };
      };
    };

    environment.etc."greetd/environments".text = ''
      ${defaultEnvironment}
    '';
  };
}

{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.noctalia;
in {
  options = {
    custom.programs.noctalia = {
      enable = lib.mkEnableOption "Enable Noctalia desktop shell";

      wallpaper = lib.mkOption {
        type = lib.types.str;
        description = "Path to wallpaper";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.noctalia = {
      enable = true;

      settings = {
        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Ayu";
        };

        wallpaper = {
          enabled = true;
          default.path = cfg.wallpaper;
        };

        shell = {
          polkit_agent = true;
          setup_wizard_enabled = false;
          screen_time_enabled = true;

          panel = {
            transparency_mode = "glass";
          };

          screen_corners = {
            enabled = true;
            size = 20;
          };
        };

        control_center_placement = "floating";
        wallpaper_placement = "floating";
        session_placement = "floating";

        open_near_click_control_center = true;

        bar.default = {
          background_opacity = 0.8;

          capsule = true;
          capsule_opacity = 0.0;
        };

        idle = {
          behavior = {
            lock = {
              timeout = 300;
              enabled = true;
            };

            screen-off = {
              timeout = 360;
              enabled = true;
            };

            suspend = {
              timeout = 600;
              enabled = true;
            };
          };
        };

        calendar.enabled = true;

        location = {
          auto_locate = true;
        };
      };

      systemd.enable = true;
    };

    custom.wm.applications = [
      {
        executable = "${lib.getExe config.programs.noctalia.package} msg panel-toggle launcher";
        keybind = "$mod+space";
      }
      {
        executable = "${lib.getExe config.programs.noctalia.package} msg panel-toggle control-center";
        keybind = "$mod";
      }
    ];
  };
}

{
  lib,
  config,
  pkgs,
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

      homeassistant.enable = lib.mkEnableOption "Enable homeasistant support";
      headsetcontrol.enable = lib.mkEnableOption "Enable headsetcontrol support";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [bitwarden-cli];

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

            control_center_placement = "floating";
            wallpaper_placement = "floating";
            session_placement = "floating";

            open_near_click_control_center = true;
          };

          screen_corners = {
            enabled = true;
            size = 20;
          };
        };

        bar.default = {
          start = ["launcher" "workspaces" "media" "weather"];
          center = ["clock"];
          end =
            ["privacy" "tray"]
            ++ lib.optional cfg.homeassistant.enable "pozzoo/hassio:status"
            ++ ["notifications" "clipboard" "network" "bluetooth" "volume" "brightness"]
            ++ lib.optional cfg.headsetcontrol.enable "vavadik/headsetcontrol:widget"
            ++ ["battery" "session"];

          background_opacity = 0.8;

          capsule = true;
          capsule_opacity = 0.0;
        };

        dock = {
          enabled = true;

          smart_auto_hide = true;
          reserve_space = false;

          show_dots = true;
        };

        idle.behavior = {
          lock = {
            timeout = 300;
            action = "lock";
            enabled = true;
          };

          screen-off = {
            timeout = 360;
            action = "screen_off";
            enabled = true;
          };

          suspend = {
            timeout = 600;
            action = "suspend";
            enabled = true;
          };
        };

        lockscreen = {
          blurred_desktop = true;
        };

        calendar.enabled = true;

        location.auto_locate = true;

        nightlight.enabled = true;

        plugins.enabled = ["noctalia/bitwarden"] ++ lib.optional cfg.headsetcontrol.enable "vavadik/headsetcontrol" ++ lib.optional cfg.homeassistant.enable "pozzoo/hassio";
      };

      systemd.enable = true;
    };

    custom.wm.applications = [
      {
        executable = "${lib.getExe config.programs.noctalia.package} msg panel-toggle launcher";
        keybind = "$mod+space";
      }

      {
        executable = "${lib.getExe config.programs.noctalia.package} msg screenshot-region";
        keybind = "Print";
      }
    ];
  };
}

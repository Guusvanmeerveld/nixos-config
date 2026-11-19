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
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Path to wallpaper";
      };

      homeassistant.enable = lib.mkEnableOption "Enable homeasistant support";
      headsetcontrol.enable = lib.mkEnableOption "Enable headsetcontrol support";
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.sway.extraConfig = ''
      include "${config.xdg.configHome}/sway/noctalia"
    '';

    programs = {
      kitty.extraConfig = ''
        include themes/noctalia.conf
      '';

      vesktop.vencord.settings.enabledThemes = ["noctalia-material.theme.css"];

      noctalia = {
        enable = true;

        settings = {
          theme = {
            mode = "dark";
            source = "wallpaper";

            templates = {
              builtin_ids = ["kitty" "sway"];

              community_ids = ["feishin" "neovim" "heroiclauncher" "prismlauncher" "thunderbird" "discord" "libreoffice"];
            };
          };

          wallpaper = {
            enabled = true;

            transition = ["fade" "zoom"];

            directory = lib.custom.relativeToRoot "wallpapers";
            directory_dark = lib.custom.relativeToRoot "wallpapers/dark";

            automation = lib.mkIf (cfg.wallpaper == null) {
              enabled = true;
              pause_on_fullscreen = true;
            };

            default.path = lib.mkIf (cfg.wallpaper != null) cfg.wallpaper;
          };

          shell = {
            polkit_agent = true;
            setup_wizard_enabled = false;
            screen_time_enabled = true;

            launch_apps_as_systemd_services = true;

            panel = {
              transparency_mode = "solid";

              control_center_placement = "floating";
              wallpaper_placement = "floating";
              session_placement = "floating";

              open_near_click_control_center = true;
            };

            screen_corners = {
              enabled = true;
              size = 20;
            };

            window_switcher = {
              style = "compact";
              mru = true;
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

            background_opacity = 0.6;

            capsule = true;
            capsule_opacity = 0.0;
          };

          dock = {
            enabled = true;

            smart_auto_hide = true;
            reserve_space = false;

            show_dots = true;

            launcher_position = "start";

            pinned = ["vesktop" "feishin" "librewolf" "kitty"];
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

          lockscreen.blurred_desktop = true;
          location.auto_locate = true;
          nightlight.enabled = true;

          calendar = {
            enabled = true;

            week_numbers = true;
          };

          plugins.enabled = lib.optional cfg.headsetcontrol.enable "vavadik/headsetcontrol" ++ lib.optional cfg.homeassistant.enable "pozzoo/hassio";
        };

        systemd.enable = true;
      };
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
      {
        executable = "${lib.getExe config.programs.noctalia.package} msg window-switcher";
        keybind = "Alt+Tab";
      }
    ];
  };
}

{lib, ...}: let
  primary-display = "DP-3";
in {
  imports = [
    ../../../home-manager
  ];

  custom = {
    wm = {
      notifications.swaync.enable = true;
      lockscreens.swaylock.enable = true;
      docks.nwg-dock.enable = true;

      bars.waybar = {
        enable = true;

        features = {
          wireguard = true;
          hcfs = true;
        };
      };

      wayland.sway = {
        enable = true;

        output = {
          "DP-3" = {
            mode = "2560x1440@74.89Hz";
            bg = "${../wallpaper-right.png} stretch";
            pos = "2560 0";
          };

          "HDMI-A-1" = {
            mode = "2560x1440@74.968Hz";
            bg = "${../wallpaper-left.png} stretch";
            pos = "0 0";
          };
        };

        workspaceOutputAssign = [
          {
            output = "HDMI-A-1";
            workspaces = lib.range 1 3;
          }
          {
            output = "DP-3";
            workspaces = lib.range 4 9;
          }
        ];

        input = {
          "type:pointer" = {
            accel_profile = "flat";
            pointer_accel = "-0.25";
          };
        };
      };
    };

    xdg.portals = {
      enable = true;

      wlr.settings = {
        # Configure main display to automatically get picked.
        screencast = {
          max_fps = 60;
          chooser_type = "none";
          output_name = primary-display;
        };
      };
    };

    services = {
      syncthing.enable = true;
      kdeconnect.enable = true;
      mpd.enable = true;
    };

    programs = {
      default.enable = true;

      messaging.enable = true;

      games = {
        enable = true;
      };

      theming.enable = true;

      office.enable = true;

      development = {
        enable = true;
      };

      cli = {
        default.enable = true;

        atuin = {
          enable = true;
          server = "https://atuin.guusvanmeerveld.dev";
        };
      };

      openshot.enable = true;
      jellyfin.enable = true;
      cantata.enable = true;
      rofi.enable = true;
      parsec.enable = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}

{lib, ...}: let
  primary-display = "DP-2";
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
        };
      };

      wayland.sway = {
        enable = true;

        output = {
          "DP-2" = {
            mode = "3440x1440@164.900Hz";
            bg = "${../wallpaper.png} stretch";
            pos = "1440 420";
          };

          "HDMI-A-1" = {
            mode = "2560x1440@74.968Hz";
            transform = "90";
            bg = "${../2nd-monitor.jpg} stretch";
            pos = "0 0";
          };
        };

        workspaceOutputAssign = [
          {
            output = "HDMI-A-1";
            workspaces = lib.range 1 2;
          }
          {
            output = "DP-2";
            workspaces = lib.range 3 9;
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

    applications = {
      development = {
        rust.enable = true;
        utils.enable = true;
      };

      services = {
        syncthing.enable = true;
        kdeconnect.enable = true;
        # gpu-screen-recorder = {
        #   enable = true;

        #   options = {
        #     window = "portal";

        #     # Audio devices to monitor in recording
        #     audio = [];
        #   };
        # };

        mpd.enable = true;
        updater.enable = true;
      };

      shell = {
        default.enable = true;

        atuin = {
          enable = true;
          server = "https://atuin.guusvanmeerveld.dev";
        };
      };

      graphical = {
        default.enable = true;

        openshot.enable = true;
        jellyfin.enable = true;
        cantata.enable = true;
        rofi.enable = true;
        parsec.enable = true;

        messaging.enable = true;

        games = {
          enable = true;

          scarab.enable = true;

          emulators = {
            desmume.enable = true;
            ryujinx.enable = true;
          };
        };

        theming.enable = true;

        office.enable = true;
        development = {
          enable = true;
          digital.enable = true;
        };
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}

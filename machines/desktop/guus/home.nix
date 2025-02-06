{...}: let
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
          "DP-3" = {
            mode = "3440x1440@164.900Hz";
            bg = "${../wallpaper.png} stretch";
            pos = "0 0";
          };
        };

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

      freetube = {
        enable = true;
        defaultResolution = "1440";
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}

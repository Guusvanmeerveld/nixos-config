{
  outputs,
  config,
  ...
}: {
  imports = [
    ../../home-manager/modules

    outputs.homeManagerModules.spotdl
  ];

  home = {
    username = "guus";
    homeDirectory = "/home/guus";
  };

  services.spotify-sync = {
    enable = true;

    schedule = "daily";

    secrets = {
      enable = true;

      file = "${config.home.homeDirectory}/.spotdl/secrets";
    };

    playlists = [
      "4spxZBgI17MSVcge6xf1q4"
      "1WX2j9iSys7lFzIYLqcoa5"
      "3vUUkBJA1eLDeSNWvKhywJ"
      "0mrDFPvKx2dxdvzlNBpcF7"
      "5afGQMeVJlIuu0QqrkP3BW"
      "6otws51PAr05osdp8pfAFB"
      "4UDFphGM1tLANTPypCwHdm"
      "6W4oQ2g91Q6CqCiQ62ir5n"
    ];
  };

  custom = {
    wm = {
      notifications.swaync.enable = true;
      lockscreens.swaylock.enable = true;

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
            bg = "${./wallpaper.png} stretch";
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
          output_name = "DP-2";
        };
      };
    };

    applications = {
      development = {
        rust.enable = true;
      };

      services = {
        syncthing.enable = true;
        mconnect.enable = true;
        gpu-screen-recorder = {
          enable = true;

          options = {
            window = "DP-2";

            # Audio devices to monitor in recording
            audio = [];
          };
        };

        mpd.enable = true;
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

        messaging.enable = true;

        games = {
          enable = true;

          emulators.desmume.enable = true;
        };

        theming.enable = true;

        office.enable = true;
        development.enable = true;
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}

{
  outputs,
  config,
  lib,
  pkgs,
  ...
}: let
  primary-display = "DP-2";
in {
  imports = [
    ../../home-manager

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

    playlist = {
      enable = true;

      directory = config.services.mpd.playlistDirectory;

      list = [
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
  };

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
            bg = "${./wallpaper.png} stretch";
            pos = "1440 420";
          };

          "HDMI-A-1" = {
            mode = "2560x1440@74.968Hz";
            transform = "90";
            bg = "${./2nd-monitor.jpg} stretch";
            pos = "0 0";
          };
        };

        startup = [
          {
            # Configure primary X11 display for XWayland applications (mainly games).
            path = lib.getExe (pkgs.writeShellApplication {
              name = "set-primary-x11-display";

              runtimeInputs = with pkgs; [xorg.xrandr];

              text = ''
                xrandr --output ${primary-display} --primary
              '';
            });

            runOnRestart = true;
          }
        ];

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
        mconnect.enable = true;
        gpu-screen-recorder = {
          enable = true;

          options = {
            window = "portal";

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
        qbittorrent.enable = true;
        cantata.enable = true;
        rofi.enable = true;

        messaging.enable = true;

        games = {
          enable = true;

          scarab.enable = true;

          emulators.desmume.enable = true;
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

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
      launchers.rofi.enable = true;
      widgets.eww.enable = true;

      bars.waybar = {
        enable = true;

        features = {
          wireguard = true;
        };
      };

      wayland.sway = {
        enable = true;

        output = {
          "HDMI-A-1" = {
            mode = "2560x1440@74.89Hz";
            bg = "${../wallpaper-right.png} stretch";
            pos = "2560 0";
          };

          "DP-1" = {
            mode = "2560x1440@74.968Hz";
            bg = "${../wallpaper-left.png} stretch";
            pos = "0 0";
          };
        };

        workspaceOutputAssign = [
          {
            output = "DP-1";
            workspaces = lib.range 1 3;
          }
          {
            output = "HDMI-A-1";
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
      kdeconnect.enable = true;
      vscode-server.enable = true;
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
        gpg.enable = true;

        atuin = {
          enable = true;
          server = "https://atuin.guusvanmeerveld.dev";
        };
      };

      jellyfin.enable = true;
      parsec.enable = true;
      eduvpn.enable = true;

      freetube = {
        enable = true;
        defaultResolution = "1440";
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}

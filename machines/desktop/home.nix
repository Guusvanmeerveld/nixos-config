{...}: {
  imports = [
    ../../home-manager/modules
  ];

  home = {
    username = "guus";
    homeDirectory = "/home/guus";
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

    applications = {
      development = {
        rust.enable = true;
      };

      services = {
        syncthing.enable = true;
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

        jellyfin.enable = true;

        rofi.enable = true;

        messaging.enable = true;
        games.enable = true;
        office.enable = true;
        development.enable = true;
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}

{...}: {
  imports = [
    ../../home-manager
  ];

  home = {
    username = "guus";
    homeDirectory = "/home/guus";
  };

  custom = {
    xdg.portals.enable = true;

    wm = {
      notifications.swaync.enable = true;
      lockscreens.swaylock.enable = true;
      docks.nwg-dock.enable = true;

      bars.waybar = {
        enable = true;
        features = {
          battery = true;
          backlight = true;
          power-profiles = true;
          wireguard = true;
        };
      };

      wayland.sway = {
        enable = true;

        keybinds = {
          backlight = true;
        };

        output = {
          "eDP-1" = {
            mode = "1920x1080@60Hz";
            bg = "${./wallpaper.jpg} stretch";
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
        kdeconnect.enable = true;
        updater.enable = true;
        poweralertd.enable = true;
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

        games.minecraft.enable = true;

        rofi.enable = true;

        theming.enable = true;
        messaging.enable = true;
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

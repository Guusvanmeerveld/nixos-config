{...}: {
  imports = [
    ../../../home-manager
  ];

  custom = {
    wm = {
      notifications.swaync.enable = true;
      lockscreens.swaylock.enable = true;
      launchers.rofi.enable = true;

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
            bg = "${../wallpaper.png} stretch";
          };
        };
      };
    };

    xdg.portals.enable = true;

    services = {
      kdeconnect.enable = true;
      poweralertd.enable = true;
    };

    programs = {
      default.enable = true;

      theming.enable = true;
      messaging.enable = true;
      office.enable = true;

      development = {
        enable = true;
      };

      games.minecraft.enable = true;

      cli = {
        default.enable = true;
        gpg.enable = true;

        atuin = {
          enable = true;
          server = "https://atuin.guusvanmeerveld.dev";
        };
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}

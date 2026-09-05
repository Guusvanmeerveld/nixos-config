{lib, ...}: {
  imports = [
    (lib.custom.relativeToRoot "home-manager")
  ];

  custom = {
    wm = {
      lockscreens.swaylock.enable = true;
      launchers.rofi.enable = true;

      bars.waybar = {
        enable = true;
        features = {
          media = true;
        };
      };

      wayland.sway = {
        enable = true;

        useSwayFx = false;

        output = {
          "Virtual-1" = {
            mode = "1920x1080@60Hz";
            bg = "${../wallpaper.jpg} stretch";
          };
        };
      };
    };

    programs = {
      default-apps.enable = true;
      cli.default-apps.enable = true;
      office.default-apps.enable = true;
      theming.default-apps.enable = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}

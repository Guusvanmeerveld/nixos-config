{...}: {
  imports = [
    ../../../home-manager
  ];

  custom = {
    wm = {
      lockscreens.swaylock.enable = true;

      bars.waybar = {
        enable = true;
        features = {
          media = true;
        };
      };

      wayland.sway = {
        enable = true;

        useFx = false;

        output = {
          "Virtual-1" = {
            mode = "1920x1080@60Hz";
            bg = "${./wallpaper.jpg} stretch";
          };
        };
      };
    };

    programs = {
      cli = {
        default.enable = true;

        atuin = {
          enable = true;
          server = "https://atuin.guusvanmeerveld.dev";
        };
      };

      default.enable = true;

      rofi.enable = true;

      office.enable = true;
      development.enable = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}

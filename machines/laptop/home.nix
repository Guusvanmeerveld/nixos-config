{outputs, ...}: {
  imports = [
    ../../home-manager/modules
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      outputs.overlays.vscode-marketplace
      outputs.overlays.rust
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "guus";
    homeDirectory = "/home/guus";
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  custom = {
    wm = {
      bars.waybar = {
        enable = true;
        features = {
          battery = true;
          backlight = true;
          power-profiles = true;
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

        messaging.enable = true;
        office.enable = true;
        development.enable = true;
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}

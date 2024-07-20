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

  home.file = {
    ".background-image".source = ./wallpaper.png;
  };

  # programs.autorandr = {
  #   enable = true;
  #   profiles = {
  #     default = let
  #       primary = {
  #         # name: $ xrandr
  #         name = "DisplayPort-1";
  #         # fingerprint: $ autorandr --fingerprint
  #         fingerprint = "00ffffffffffff0010ac12a25338463029210104b55022783b3da0b5483eb7250d5054a54b00714f8180a9c0d1c00101010101010101e77c70a0d0a0295030203a0020513100001a000000ff00365850423253330a2020202020000000fc004157333432334457460a202020000000fd0c30a51e1e66010a20202020202002f902033af14c3f2221201f131210040302012309070783010000e305c301e6060501664d02721a0000030330a5008466024d03a500000000e200ea6fc200a0a0a055503020350020513100001a09ec00a0a0a067503020350020513100001a4dd2707ed0a046500e203a0020513100001a00000000000000000000000000000064701279030003013cd58300047f079f002f801f0037042f0002000400555e0004ff099f002f801f009f05280002000400278e01046f0d9f002f801f009f05140102000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e90";
  #       };
  #     in {
  #       config = {
  #         "${primary.name}" = {
  #           enable = true;
  #           mode = "3440x1440";
  #           primary = true;
  #           rate = "164.90";
  #         };
  #       };
  #       fingerprint = {
  #         "${primary.name}" = "${primary.fingerprint}";
  #       };
  #     };
  #   };
  # };

  # services.autorandr.enable = true;

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

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

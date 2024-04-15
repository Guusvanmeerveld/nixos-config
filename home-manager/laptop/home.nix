{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../modules
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
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
    ".background-image".source = ./wallpaper.jpg;
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  custom = {
    wm = {
      theme = {
        gtk = {
          enable = true;
        };

        font = {
          name = "Fira Code";
          package = pkgs.fira-code;
        };

        background = {
          primary = "#151515";
          secondary = "#212121";

          alt = {
            primary = "#232323";
            secondary = "#353535";
          };
        };

        text = {
          primary = "#eeeeee";
          secondary = "#cecece";
        };

        ok = "#98c379";
        warn = "#e06c75";
        error = "#be5046";

        primary = "#2997f2";
      };

      i3 = {
        enable = true;
      };
    };

    applications = {
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

        messaging.enable = true;
        office.enable = true;
        development.enable = true;
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}

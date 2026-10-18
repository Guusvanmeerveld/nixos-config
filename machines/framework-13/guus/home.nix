{
  pkgs,
  lib,
  ...
}: {
  imports = [
    (lib.custom.relativeToRoot "home-manager")
  ];

  home.packages = with pkgs; [powertop];

  services.easyeffects = {
    enable = true;

    preset.output = "fw13-easy-effects";

    extraPresets = {
      fw13-easy-effects = builtins.fromJSON (builtins.readFile ./fw13-easy-effects.json);
    };
  };

  custom = {
    wm.wayland.sway = {
      enable = true;

      output = {
        "eDP-1" = {
          mode = "2256x1504@59.999Hz";
          scale = toString 1.5;
          color_profile = "icc ${./BOE_CQ_______NE135FBM_N41_03.icm}";
        };

        "*" = {
          bg = "${../wallpaper.png} stretch";
        };
      };
    };

    xdg.portals = {
      enable = true;

      wlr.settings = {
        # Configure main display to automatically get picked.
        screencast = {
          max_fps = toString 60;
          chooser_type = "none";
          output_name = "eDP-1";
        };
      };
    };

    services = {
      kdeconnect.enable = true;
      poweralertd.enable = true;
      playerctld.enable = true;
      ntfy-client = {
        enable = true;

        servers = [
          {
            url = "ntfy.sun.guusvanmeerveld.dev";
            topics = ["jellyseerr" "power" "twitch-miner" "disk-space" "uptime" "free-epic-games"];
          }
        ];
      };
    };

    programs = {
      noctalia = {
        enable = true;

        wallpaper = "${../wallpaper.png}";
      };

      default-apps.enable = true;
      theming.default-apps.enable = true;
      messaging = {
        default-apps.enable = true;
        vesktop.autostart = false;
      };
      office.default-apps.enable = true;
      cli = {
        default-apps.enable = true;
        gpg.enable = true;
      };

      games.minecraft.enable = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}

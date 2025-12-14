{pkgs, ...}: {
  imports = [
    ../../../home-manager
  ];

  home.packages = with pkgs; [powertop];

  # By default, the speakers do not sound very balanced (due to downward firing speakers), so you may want to use an equalizer to fix this. The recommended method is to install EasyEffects and use the official preset
  # From: https://wiki.archlinux.org/title/Framework_Laptop_13#Speakers
  services.easyeffects = {
    enable = true;

    preset = "fw13-easy-effects";

    extraPresets = {
      fw13-easy-effects = builtins.fromJSON (builtins.readFile ./fw13-easy-effects.json);
    };
  };

  custom = {
    wm = {
      notifications.swaync.enable = true;
      lockscreens.gtklock.enable = true;
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

        output = {
          "eDP-1" = {
            mode = "2256x1504@59.999Hz";
            scale = toString 1.5;
            bg = "${../wallpaper.png} stretch";
          };
        };
      };
    };

    xdg.portals.enable = true;

    services = {
      kdeconnect.enable = true;
      poweralertd.enable = true;
      playerctld.enable = true;
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
      };

      eduvpn.enable = true;
      jellyfin-client.enable = false;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}

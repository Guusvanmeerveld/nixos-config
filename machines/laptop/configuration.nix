{...}: {
  imports = [
    ../../nixos

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 0;
  };

  networking.hostName = "laptop";

  networking.networkmanager.enable = true;

  services.logind = {
    lidSwitch = "hibernate";
    # powerKeyLongPress = "reboot";
    # powerKey = "poweroff";
  };

  services.power-profiles-daemon.enable = true;

  custom = {
    user.name = "guus";

    security.keyring.enable = true;

    hardware = {
      backlight.enable = true;
      bluetooth.enable = true;
      upower.enable = true;

      sound.pipewire.enable = true;

      video = {
        amd.enable = true;

        outputs = {
          "eDP-1" = {
            resolution = "1920x1080";
            refreshRate = 60.0;
            background = "${./wallpaper.jpg} stretch";
          };
        };
      };
    };

    applications = {
      shell.zsh.enable = true;

      mconnect.enable = true;
      android.enable = true;
      graphical = {
        thunar.enable = true;
        steam.enable = true;
      };

      services = {
        docker = {
          enable = true;
        };
      };

      wireguard.openFirewall = true;
    };

    dm.greetd = {
      enable = true;
    };

    wm.wayland.sway.enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

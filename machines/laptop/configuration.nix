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
    lidSwitch = "poweroff";
    # powerKeyLongPress = "reboot";
    # powerKey = "poweroff";
  };

  services.power-profiles-daemon.enable = true;

  custom = {
    users."guus" = {
      isSuperUser = true;

      homeManager = {
        enable = true;

        config = ./guus/home.nix;
      };

      groups = ["docker" "adbusers"];
    };

    security.keyring.enable = true;

    hardware = {
      backlight.enable = true;
      bluetooth.enable = true;
      upower.enable = true;
      plymouth.enable = true;

      sound.pipewire.enable = true;

      video = {
        amd.enable = true;
      };
    };

    programs = {
      zsh.enable = true;
      adb.enable = true;
      steam.enable = true;
    };

    virtualisation.docker.enable = true;

    services = {
      gvfs.enable = true;

      syncthing.openFirewall = true;
    };

    dm.greetd = {
      enable = true;

      outputs = {
        "eDP-1" = {
          resolution = "1920x1080";
          refreshRate = 60.0;
          background = "${./wallpaper.jpg} stretch";
        };
      };
    };

    wm.wayland.sway.enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

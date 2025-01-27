{...}: {
  imports = [
    ../../nixos

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  networking.hostName = "thuisthuis";

  networking.networkmanager.enable = true;

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    systemd-boot = {
      enable = true;
      configurationLimit = 2;
    };

    timeout = 0;
  };

  custom = {
    users."guus" = {
      isSuperUser = true;

      homeManager = {
        enable = true;

        config = ./guus/home.nix;
      };
    };

    security.keyring.enable = true;

    hardware = {
      openrgb.enable = true;
      plymouth.enable = true;

      video = {
        amd.enable = true;
      };

      sound.pipewire.enable = true;
      input = {
        corsair.enable = true;
        logitech.enable = true;
      };
    };

    programs = {
      zsh.enable = true;
      steam.enable = true;
    };

    services = {
      gamemode.enable = true;
      gvfs.enable = true;

      syncthing.openFirewall = true;
      kdeconnect.openFirewall = true;
    };

    virtualisation = {
      qemu = {
        enable = true;
        graphical = true;
      };

      docker.enable = true;
    };

    dm.greetd = {
      enable = true;

      outputs = {
        "DP-3" = {
          resolution = "2560x1440";
          refreshRate = 74.89;
          background = "${./wallpaper.jpg} stretch";
          position = {
            x = 2560;
          };
        };

        "HDMI-A-1" = {
          resolution = "2560x1440";
          refreshRate = 74.968;
          background = "${./2nd-monitor.jpg} stretch";
        };
      };
    };

    wm.wayland.sway.enable = true;
  };
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

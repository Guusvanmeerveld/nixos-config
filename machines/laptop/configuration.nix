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

  networking = {
    hostName = "laptop";
    networkmanager.enable = true;
  };

  services.logind = {
    lidSwitch = "hibernate";
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
    certificates.enable = true;

    networking.wireguard = {
      enable = true;

      networks = {
        "garden" = {
          enable = true;
        };
      };
    };

    hardware = {
      backlight.enable = true;
      bluetooth.enable = true;
      upower.enable = true;
      plymouth.enable = true;

      sound.pipewire.enable = true;
      power.tlp.enable = true;
      video.amd.enable = true;
    };

    programs = {
      zsh.enable = true;
      adb.enable = true;
      steam.enable = true;
      sudo-rs.enable = true;
    };

    virtualisation.docker.enable = true;

    services = {
      gvfs.enable = true;
      kdeconnect.openFirewall = true;

      caddy.enable = true;
      syncthing = {
        enable = true;

        folders = {
          "code" = "~/Code";
          "minecraft" = "~/Minecraft";
          "music" = "~/Music";
          "games" = "~/Backups/Games";
          "dictionaries" = "~/.config/dictionaries";
          "firefox-profile" = "~/.librewolf/default";
        };

        caddy.url = "https://syncthing.laptop";
        openFirewall = true;
      };

      # qbittorrent.enable = true;
    };

    dm.greetd = {
      enable = true;

      outputs = {
        "eDP-1" = {
          resolution = "1920x1080";
          refreshRate = 60.0;
          background = "${./wallpaper.png} stretch";
        };
      };
    };

    wm.wayland.sway.enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

{lib, ...}: {
  imports = [
    (lib.custom.relativeToRoot "nixos")

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "thuisthuis";

    # Required for ZFS
    hostId = "379d3527";

    networkmanager.enable = true;
  };

  # Disable since networkmanager is responsible for managing main internet connection
  # https://mynixos.com/nixpkgs/option/systemd.network.wait-online.enable
  systemd.network.wait-online.enable = false;

  # Use SystemD's builtin DNS resolver
  services.resolved = {
    enable = true;
    settings.Resolve.Cache = "yes";
  };

  # Bootloader.
  boot = {
    tmp = {
      useTmpfs = true;
    };

    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };

      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };

      timeout = 0;
    };

    kernelModules = ["ntsync"];
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

    fs.zfs.enable = true;

    hardware = {
      video.amd.enable = true;

      openrgb.enable = true;
      plymouth.enable = true;
      bluetooth.enable = true;

      sound.pipewire.enable = true;

      input = {
        corsair.enable = true;
        logitech.enable = true;
      };
    };

    networking = {
      wireguard = {
        enable = true;

        networks = {
          "garden" = {
            enable = true;
          };
        };
      };
    };

    programs = {
      zsh.enable = true;
      steam.enable = true;
      sudo-rs.enable = true;
    };

    services = {
      beszel.agent = {
        enable = true;

        openFirewall = true;
      };

      gamemode.enable = true;
      gvfs.enable = true;

      kdeconnect.openFirewall = true;

      syncthing = {
        enable = true;

        folders = {
          "code" = "~/Code";
          "minecraft" = "~/Minecraft";
          "games" = "~/Backups/Games";
          "seedvault-backup" = "~/Backups/Phone";
          "firefox-sync" = "~/Backups/Librewolf";
          "dictionaries" = "~/.config/dictionaries";
          "documents" = "~/Documents";
          "desktop-pictures" = "~/Pictures";
        };

        openFirewall = true;
      };
    };

    virtualisation = {
      qemu = {
        enable = true;
        graphical = true;
      };

      waydroid.enable = true;

      podman.enable = true;
    };

    dm.noctalia-greeter = {
      enable = true;

      output = {
        name = "HDMI-A-1";

        refresh_rate = 180.003;
        width = 1920;
        height = 1080;
      };

      wallpaper = "${./wallpaper-right.png}";
    };

    de.noctalia.enable = true;
    wm.wayland.sway.enable = true;
  };
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

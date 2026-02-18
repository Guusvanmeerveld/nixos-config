_: {
  imports = [
    ../../nixos

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  fileSystems = {
    "/mnt/games" = {
      device = "homework/games";
      fsType = "zfs";
    };
  };

  powerManagement.cpuFreqGovernor = "performance";

  networking = {
    hostName = "thuisthuis";

    # Required for ZFS
    hostId = "379d3527";

    useDHCP = false;
  };

  systemd.network = {
    enable = true;

    networks."10-wan" = {
      matchConfig.Name = "enp34s0";

      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = false;

        DNSOverTLS = false;
        DNSSEC = false;
      };

      # Route all DNS requests to this FQDN via network router
      domains = ["~sun.guusvanmeerveld.dev" "~localdomain"];

      linkConfig.RequiredForOnline = "routable";
    };
  };

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

    linux.cachyos.useKernel = true;

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
      gamemode.enable = true;
      gvfs.enable = true;

      restic.client.enable = true;

      kdeconnect.openFirewall = true;

      caddy.enable = true;
      syncthing = {
        enable = true;

        folders = {
          "code" = "~/Code";
          "minecraft" = "~/Minecraft";
          "music" = "~/Music";
          "games" = "~/Backups/Games";
          "seedvault-backup" = "~/Backups/Phone";
          "firefox-sync" = "~/Backups/Librewolf";
          "dictionaries" = "~/.config/dictionaries";
        };

        caddy.url = "http://syncthing.thsths";
        openFirewall = true;
      };
    };

    virtualisation = {
      qemu = {
        enable = true;
        graphical = true;
      };

      waydroid.enable = true;

      docker.enable = true;
    };

    alerts = {
      power.enable = true;
      disk-space.enable = true;
    };

    dm.greetd.enable = true;

    wm = {
      wayland.sway.enable = true;
      lockscreens.gtklock.enable = true;
    };
  };
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

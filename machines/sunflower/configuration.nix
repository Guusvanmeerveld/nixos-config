# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  # config,
  pkgs,
  ...
}: {
  imports = [
    ../../nixos

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  fileSystems = {
    "/" = {
      device = "root/root";
      fsType = "zfs";
    };

    "/nix" = {
      device = "root/nix";
      fsType = "zfs";
    };

    "/var" = {
      device = "root/var";
      fsType = "zfs";
    };

    "/home" = {
      device = "root/home";
      fsType = "zfs";
    };

    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };

    # "/mnt/data" = {
    #   device = "zpool/data";
    #   fsType = "zfs";
    # };

    # "/mnt/bigdata/restic" = {
    #   device = "bigdata/restic";
    #   fsType = "zfs";
    # };

    # "/mnt/bigdata/syncthing" = {
    #   device = "bigdata/syncthing";
    #   fsType = "zfs";
    # };

    # "/mnt/bigdata/immich" = {
    #   device = "bigdata/immich";
    #   fsType = "zfs";
    # };

    # "/mnt/bigdata/media" = {
    #   device = "bigdata/media";
    #   fsType = "zfs";
    # };
  };

  boot = {
    tmp.cleanOnBoot = true;

    loader = {
      systemd-boot.enable = true;
      timeout = 0;
    };

    binfmt.emulatedSystems = ["aarch64-linux"];
  };

  hardware.graphics = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [radeontop nvtopPackages.amd];

  networking = {
    hostName = "sunflower";
    hostId = "deadb33f";
    networkmanager.enable = true;
  };

  custom = {
    users."guus" = {
      isSuperUser = true;

      homeManager = {
        enable = true;

        config = ./guus/home.nix;
      };

      ssh.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKIdNGCw0MURAoLliBBn3+LGGXZu17yNYUuOAMDHXoqj guus@thuisthuis"
      ];
    };

    hardware.power.thermald.enable = true;

    certificates.enable = true;

    fs.zfs.enable = true;

    networking.wireguard = {
      enable = true;

      networks = {
        "garden" = {
          enable = true;
          keepAlive = true;
        };
      };
    };

    services = {
      openssh.enable = true;
      fail2ban.enable = true;
      autoUpgrade.enable = true;
      restic.client.enable = true;

      caddy = {
        enable = true;

        # ca = {
        #   enable = true;

        #   cert = "${../../nixos/certificates/sunflower.crt}";
        #   key = "/secrets/caddy/ca/root.key";
        # };

        openFirewall = true;
      };

      # immich = {
      #   enable = true;

      #   mediaDir = "/mnt/bigdata/apps/immich/upload";

      #   caddy.url = "http://immich.sun";
      # };

      # jellyfin = {
      #   enable = true;

      #   caddy.url = "http://jellyfin.sun";
      # };

      # jellyseerr = {
      #   enable = true;

      #   caddy.url = "https://jellyseerr.sun";
      # };

      # uptime-kuma = {
      #   enable = true;

      #   caddy.url = "https://uptime.sun";
      # };

      # homeassistant = {
      #   enable = true;

      #   caddy.url = "https://homeassistant.sun";
      # };

      # ntfy = {
      #   enable = true;

      #   caddy.url = "https://ntfy.sun";
      # };

      # miniflux = {
      #   enable = true;

      #   adminCredentialsFile = "/secrets/miniflux/adminCredentials";

      #   caddy.url = "https://miniflux.sun";
      # };

      # vaultwarden = {
      #   enable = true;

      #   environmentFile = "/secrets/vaultwarden/environmentFile";

      #   caddy.url = "https://bitwarden.sun";
      # };

      # traccar = {
      #   enable = true;

      #   caddy.url = "https://traccar.sun";
      # };

      # radicale = {
      #   enable = true;

      #   htpasswdFile = "/secrets/radicale/htpasswdFile";

      #   caddy.url = "https://radicale.sun";
      # };

      # atuin = {
      #   enable = true;

      #   caddy.url = "https://atuin.sun";
      # };

      # unifi = {
      #   enable = true;

      #   openFirewall = true;

      #   caddy.url = "https://unifi";
      # };

      # free-epic-games = {
      #   enable = true;

      #   email = "mail@guusvanmeerveld.dev";

      #   ntfy.url = "http://0.0.0.0:${toString config.custom.services.ntfy.port}";

      #   caddy.url = "http://free-epic-games.sun";
      # };

      # twitch-miner = {
      #   enable = true;
      #   username = "guusvanmeerveld";

      #   ntfy.url = "http://localhost:${toString config.custom.services.ntfy.port}";
      # };

      # mealie = {
      #   enable = true;

      #   caddy.url = "https://mealie.sun";
      # };

      dnsmasq = {
        enable = true;

        openFirewall = true;

        redirects = {
          "mijnmodem.kpn" = "192.168.2.254";

          ".sun" = "192.168.2.35";

          "unifi" = "192.168.2.35";
          "unifi.home" = "192.168.2.35";
        };
      };
    };

    alerts = {
      power.enable = true;
      disk-space.enable = true;
    };

    programs = {
      zsh.enable = true;
      sudo-rs.enable = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}

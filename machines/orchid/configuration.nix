# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  lib,
  shared,
  ...
}: {
  imports = [
    ../../nixos

    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  boot.blacklistedKernelModules = ["onboard_usb_hub"];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = ["noatime"];
    };

    "/mnt/data" = {
      device = "zpool/data";
      fsType = "zfs";
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 4096;
    }
  ];

  hardware = {
    raspberry-pi."4" = {
      i2c1.enable = true;
    };
  };

  # Enable networking
  networking = {
    networkmanager.enable = true;

    hostName = "orchid";

    # Required for ZFS
    hostId = "04ae0999";
  };

  custom = {
    users."guus" = {
      isSuperUser = true;

      homeManager = {
        enable = true;

        config = ./guus/home.nix;
      };

      ssh.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPveisofM9+vfj896DbwpKZJETzE3pqNA86y3Wdcdbt1 guus@desktop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGu7eHkmd1YUi3sjbYG299Gvwlq2fpy2AIlLTXgUR49j guus@laptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKw8JJfcBC8cITSr9UWo6rG9pBL3U5oZlokBF/BoyCYN guus@thuisthuis"
      ];
    };

    fs.zfs.enable = true;

    hardware = {
      argon40 = {
        enable = true;
        eon.enable = true;
      };
    };

    networking.wireguard = let
      gardenConfig = shared.wireguard.networks.garden;
      orchidConfig = gardenConfig.clients.orchid;
    in {
      enable = true;
      openFirewall = true;

      interfaces = {
        "garden" = {
          addresses = ["${orchidConfig.address}/24"];
          privateKeyFile = "/secrets/wireguard/garden/private";

          clientConfig = {
            enable = true;
            server = gardenConfig.server.address;
          };

          peers = lib.singleton {
            publicKey = gardenConfig.server.publicKey;
            endpoint = "${gardenConfig.server.endpoint}:${toString gardenConfig.server.port}";
            allowedIps = ["10.10.10.0/24"];
            keepAlive = 25;
          };
        };
      };
    };

    services = {
      openssh.enable = true;
      # fail2ban.enable = true;
      autoUpgrade.enable = true;

      samba.server = {
        enable = true;

        shares = {
          iso = "/mnt/data/iso";
          games = "/mnt/data/games";
          media = "/mnt/data/media";
          nextcloud = "/mnt/data/apps/nextcloud";
          gitea = "/mnt/data/apps/gitea";
          syncthing = "/mnt/data/apps/syncthing";
          immich = "/mnt/data/apps/immich";
        };
      };

      motd = {
        enable = true;

        settings = {
          fileSystems = {
            "data" = "/mnt/data";
          };
        };
      };
    };

    programs.zsh.enable = true;

    builders = {
      enable = true;

      machines = [
        {
          hostName = "crocus";
          system = "aarch64-linux";
        }
      ];
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}

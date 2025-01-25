# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  lib,
  ...
}: {
  imports = [
    ../../../nixos

    inputs.nixos-hardware.nixosModules.raspberry-pi-4

    ./zfs.nix

    ./samba.nix
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = ["noatime"];
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 1024;
    }
  ];

  hardware = {
    raspberry-pi."4" = {
      i2c1.enable = true;
    };
  };

  networking.hostName = "orchid";

  # Enable networking
  networking.networkmanager.enable = true;

  custom = {
    user = {
      name = "guus";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPveisofM9+vfj896DbwpKZJETzE3pqNA86y3Wdcdbt1 guus@desktop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGu7eHkmd1YUi3sjbYG299Gvwlq2fpy2AIlLTXgUR49j guus@laptop"
      ];
    };

    hardware = {
      argon40 = {
        enable = true;
        eon.enable = true;
      };
    };

    services = {
      openssh.enable = true;
      fail2ban.enable = true;

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
  };

  builders = {
    enable = true;

    machines = [
      {
        hostName = "crocus";
        system = "aarch64-linux";
      }
    ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{
  lib,
  shared,
  ...
}: {
  imports = [
    ../../nixos

    ./secrets.nix

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader = {
    grub = {
      device = "/dev/vda";
    };
  };

  networking.hostName = "rose";

  # Enable networking
  networking.networkmanager.enable = true;

  networking.firewall = {
    allowedTCPPorts = [25 143 465 587 993];
    allowedUDPPorts = [51820];
  };

  custom = {
    users."guus" = {
      isSuperUser = true;

      homeManager = {
        enable = true;

        config = ./guus/home.nix;
      };

      ssh.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDYlOu/F/BdrbrfTV3M1UzKNmnOzMhgjvJpzmtjmqIALoDFLrDl9UJIUdkrbe2Wc/XxSC81+3SBjpHdJmnCEWZXqjPooE6LyLC+wUvTSeVyL/OmdeysjT998TBmI5AmLYxq+7aPIEYvi4ThRL3pYe0pqqpcjVYl2vFtV3Tl4++4M19pBYxfZ5cTu7q0whvQk5JJs3HuLYYqjLhYHzUowsUfqinlbcExY9N0wcUk5XP30fwyyjcB4V7rytqV69jt7sT/Qm1A51U8TTuAlCS+nqzowilstzntdxW17FdBsD8EvWHhQ9jk/sjmLik2axjz4eHCaFJTupOnxX/vwraw81i1KDG9aOTfcBiK8eHElcqUT+kKo5/r6LEmFrwtyIdHvsxL0gOR1sH1Hb1c1VWsuv/7SMRmYeSfyTlGw27vCNOcqCCgGiXsDYmvMI+v/huFjJYHi+KyA8zSeTlPijX/iP4VZOlo2waLuin6u/VdiZqxvoFHMidlQtR1tP5j2E8YbOM= guus@desktop"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCgJ+CtiME7co6zBpdQytDUCF3lmM53dSE6meLHg2IJEt8EhX1QT4B0g4ep9fjCwAgmGAFjhUoQBPFwMaybWVeQWaxy8YAi+IexlJcQgPOBCapbtXgESAOuimpSyC9O0SQWULKeK8fuE1IpSBgXJXmhHP9SViu5RJ9YhCI17qvE2wHA9bFJGs+do/pwvjy3QLulVMDfxuft3HKAafEKTIqy1/OKqxeFalVOpZhbEsTx7gmKMfncHhkCTU7eE1s2umet+bD3kOxWwfvJuztxz64roe+NOuDC5m1VaglkHF8a1Ohgj4wS6g0/SC1jQk69P/aVCXGRhvVGCvCTDeUeaPOuc1sDbOXmsA9RlBhkIOUAXx1frdcTNp3rJ1nV0hKC+0QIbyZZhflIgzZGT8Kc9RgseY3XQry/tmW29ax8ZM3/y+BVsW7q7lyLynsnN66j5UgUUOQs+1EwftFjPbq/yUUcXVcFdAOckeOlyxLVeSchJyqCvjEkYvk7HSDDwamHUiE= guus@laptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKIZZP73LLH+0VvUqpmTmIvU2EqmfzZQxspCDeODa5xy guus@thuisthuis"
      ];
    };

    networking.wireguard = let
      gardenConfig = shared.wireguard.networks.garden;
      roseConfig = gardenConfig.clients.rose;
    in {
      enable = true;
      openFirewall = true;

      interfaces = {
        "garden" = {
          addresses = ["${roseConfig.address}/24"];
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

    virtualisation.docker = {
      enable = true;

      dashdot.enable = true;
      watchtower.enable = true;

      syncthing = {
        enable = true;
        openFirewall = true;
      };
    };

    services = {
      openssh.enable = true;
      fail2ban.enable = true;
      autoUpgrade.enable = true;
    };

    programs.zsh.enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

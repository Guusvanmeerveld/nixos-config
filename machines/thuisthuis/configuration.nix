{
  lib,
  shared,
  inputs,
  ...
}: {
  imports = [
    ../../nixos

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    inputs.grub2-themes.nixosModules.default
  ];

  networking.hostName = "thuisthuis";

  networking.networkmanager.enable = true;

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    # systemd-boot = {
    #   enable = true;
    #   configurationLimit = 2;
    # };

    grub = {
      enable = true;
      efiSupport = true;
      useOSProber = true;

      configurationLimit = 1;

      device = "nodev";
    };

    grub2-theme = {
      enable = true;
      theme = "whitesur";
      footer = true;
      screen = "2k";
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

      ssh.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDSyS7My9aiqxXANdqDXXXD6r7P/ngXNk62KLrDcSU38 guus@laptop"
      ];
    };

    security.keyring.enable = true;

    hardware = {
      video = {
        amd = {
          enable = true;
          polaris.enable = true;
        };
      };

      # disko = {
      #   enable = true;

      #   device = "/dev/nvme0n1";
      #   swap.size = "16G";
      # };

      openrgb.enable = true;
      plymouth.enable = true;

      sound.pipewire.enable = true;

      input = {
        corsair.enable = true;
        logitech.enable = true;
      };

      hyperx.cloud-flight-s.enable = true;
    };

    networking.wireguard = let
      gardenConfig = shared.wireguard.networks.garden;
      thuisthuisConfig = gardenConfig.clients.thuisthuis;
    in {
      enable = true;
      openFirewall = true;

      interfaces = {
        "garden" = {
          addresses = ["${thuisthuisConfig.address}/24"];
          privateKeyFile = "/secrets/wireguard/garden/private";

          clientConfig = {
            enable = true;
            server = gardenConfig.server.address;
          };

          peers = lib.singleton {
            publicKey = gardenConfig.server.publicKey;
            endpoint = "${gardenConfig.server.endpoint}:${toString gardenConfig.server.port}";
            allowedIps = ["10.10.10.0/24"];
          };
        };
      };
    };

    programs = {
      zsh.enable = true;
      steam.enable = true;
    };

    services = {
      gamemode.enable = true;
      gvfs.enable = true;
      autoUpgrade.enable = true;
      openssh.enable = true;

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
        "HDMI-A-1" = {
          resolution = "2560x1440";
          refreshRate = 74.89;
          background = "${./wallpaper-right.png} stretch";
          position = {
            x = 2560;
          };
        };

        "DP-1" = {
          resolution = "2560x1440";
          refreshRate = 74.968;
          background = "${./wallpaper-left.png} stretch";
        };
      };
    };

    wm.wayland.sway.enable = true;
  };
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

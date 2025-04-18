{...}: {
  imports = [
    ../../nixos

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  networking.hostName = "thuisthuis";

  networking.networkmanager.enable = true;

  # Bootloader.
  boot = {
    tmp = {
      cleanOnBoot = true;
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

    kernelParams = ["atkbd.reset" "usbcore.autosuspend=-1" "amdgpu.gpu_recovery=1"];
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
      mullvad.enable = true;

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
      teamviewer.enable = true;
    };

    services = {
      gamemode.enable = true;
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
          "seedvault-backup" = "~/Backups/Phone";
        };

        caddy.url = "http://syncthing.thsths";
        openFirewall = true;
      };

      # qbittorrent.enable = true;
    };

    virtualisation = {
      qemu = {
        enable = true;
        graphical = true;
      };

      docker.enable = true;

      # microvm = {
      #   enable = true;

      #   upstreamNetworkInterface = "enp34s0";

      #   vms = {
      #     media = {...}: {
      #       microvm = {
      #         shares = [
      #           {
      #             source = "/nix/store";
      #             mountPoint = "/nix/.ro-store";
      #             tag = "ro-store";
      #             proto = "virtiofs";
      #           }
      #         ];
      #       };

      #       services = {
      #         caddy = {
      #           enable = true;

      #           virtualHosts."http://media".extraConfig = ''
      #             reverse_proxy http://localhost:8096
      #           '';
      #         };

      #         radarr.enable = true;
      #         sonarr.enable = true;
      #         prowlarr.enable = true;

      #         jellyfin = {
      #           enable = true;
      #         };
      #       };

      #       users.users.root.password = "toor";
      #       services.openssh = {
      #         enable = true;
      #         settings.PermitRootLogin = "yes";
      #       };

      #       networking.firewall.allowedTCPPorts = [80];
      #     };
      #   };
      # };
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

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
    certificates.enable = true;

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
      sudo-rs.enable = true;
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

      docker.enable = true;
    };

    dm.greetd.enable = true;

    wm.wayland.sway.enable = true;
  };
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

{...}: {
  imports = [
    ../../nixos

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "desktop";
    networkmanager.enable = true;
  };

  hardware.enableRedistributableFirmware = true;

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
        configurationLimit = 20;
      };

      timeout = 0;
    };
  };

  # Prevent USB controller from awaking the system from suspend.
  services.udev.extraRules = ''
    ACTION=="add" SUBSYSTEM=="pci" ATTR{vendor}=="0x8086" ATTR{device}=="0x7a60" ATTR{power/wakeup}="disabled"
  '';

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
      openrgb.enable = true;
      plymouth.enable = true;

      video.amd.enable = true;
      power.thermald.enable = true;

      sound.pipewire.enable = true;
      input.logitech.enable = true;

      hyperx.cloud-flight-s.enable = true;
    };

    alerts = {
      power.enable = true;
      disk-space.enable = true;
    };

    programs = {
      zsh.enable = true;
      adb.enable = true;
      steam.enable = true;
      teamviewer.enable = true;
      sudo-rs.enable = true;
    };

    services = {
      gamemode.enable = true;
      gvfs.enable = true;
      autoUpgrade.enable = true;

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

        caddy.url = "http://syncthing.desktop";
        openFirewall = true;
      };

      restic.client.enable = true;
    };

    virtualisation = {
      qemu = {
        enable = true;
        graphical = true;
      };

      docker.enable = true;
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

    dm.greetd.enable = true;

    wm = {
      lockscreens.gtklock.enable = true;
      wayland.sway.enable = true;
    };
  };
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

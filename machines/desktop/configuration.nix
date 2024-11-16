{inputs, ...}: {
  imports = [
    inputs.grub2-themes.nixosModules.default

    ../../nixos

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  networking.hostName = "desktop";

  networking.networkmanager.enable = true;

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    systemd-boot = {
      enable = true;
      configurationLimit = 20;
    };

    timeout = 0;

    # grub = {
    #   enable = true;

    #   efiSupport = true;
    #   useOSProber = true;
    #   device = "nodev";
    # };

    # grub2-theme = {
    #   enable = true;
    #   theme = "tela";
    #   icon = "color";
    #   screen = "ultrawide2k";
    #   footer = true;
    # };
  };

  # Prevent USB controller from awaking the system from suspend.
  services.udev.extraRules = ''
    ACTION=="add" SUBSYSTEM=="pci" ATTR{vendor}=="0x8086" ATTR{device}=="0x7a60" ATTR{power/wakeup}="disabled"
  '';

  custom = {
    user.name = "guus";

    security.keyring.enable = true;

    hardware = {
      video = {
        amd.enable = true;

        outputs = {
          "DP-2" = {
            resolution = "3440x1440";
            refreshRate = 164.9;
            background = "${./wallpaper.png} stretch";
            position = {
              x = 1440;
              y = 420;
            };
          };

          "HDMI-A-1" = {
            resolution = "2560x1440";
            refreshRate = 74.968;
            transform = 90;
            background = "${./2nd-monitor.jpg} stretch";
            position = {
              x = 0;
              y = 0;
            };
          };
        };
      };

      sound.pipewire.enable = true;
    };

    applications = {
      shell.zsh.enable = true;

      android.enable = true;
      mconnect.enable = true;

      graphical = {
        steam.enable = true;
        teamviewer.enable = true;
        thunar.enable = true;

        gtk.enable = true;
        openrgb.enable = true;
      };

      wireguard.openFirewall = true;

      services = {
        syncthing.openFirewall = true;
        docker = {
          enable = true;
        };

        # gpu-screen-recorder.enable = true;

        gamemode.enable = true;
      };

      waydroid.enable = true;

      qemu = {
        enable = true;
        graphical = true;
      };
    };

    dm.greetd = {
      enable = true;
    };

    wm.wayland.sway.enable = true;
  };
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

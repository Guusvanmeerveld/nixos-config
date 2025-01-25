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
      openrgb.enable = true;
      plymouth.enable = true;

      video = {
        amd.enable = true;
      };

      sound.pipewire.enable = true;
      input.logitech.enable = true;
    };

    programs = {
      zsh.enable = true;
      adb.enable = true;
      steam.enable = true;
      teamviewer.enable = true;
    };

    services = {
      gamemode.enable = true;
      gvfs.enable = true;
      syncthing.openFirewall = true;

      # sunshine = {
      #   enable = true;
      #   openFirewall = true;
      # };

      # gpu-screen-recorder.enable = true;
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

    wm.wayland.sway.enable = true;
  };
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

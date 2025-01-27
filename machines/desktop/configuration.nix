{
  inputs,
  shared,
  lib,
  ...
}: {
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
    };

    services = {
      gamemode.enable = true;
      gvfs.enable = true;

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

    networking.wireguard = let
      gardenConfig = shared.wireguard.networks.garden;
      desktopConfig = gardenConfig.clients.desktop;
    in {
      enable = true;
      openFirewall = true;

      interfaces = {
        "garden" = {
          addresses = ["${desktopConfig.address}/24"];
          privateKeyFile = "/secrets/wireguard/garden/private";

          peers = lib.singleton {
            publicKey = gardenConfig.server.publicKey;
            endpoint = "${gardenConfig.server.endpoint}:${toString gardenConfig.server.port}";
            allowedIps = ["10.10.10.0/24"];
          };
        };
      };
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

{
  shared,
  lib,
  ...
}: {
  imports = [
    ../../nixos

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 0;
  };

  networking = {
    hostName = "laptop";
    networkmanager.enable = true;
  };

  services.logind = {
    lidSwitch = "hibernate";
  };

  services.power-profiles-daemon.enable = true;

  custom = {
    users."guus" = {
      isSuperUser = true;

      homeManager = {
        enable = true;

        config = ./guus/home.nix;
      };
    };

    security.keyring.enable = true;

    networking.wireguard = let
      gardenConfig = shared.wireguard.networks.garden;
      laptopConfig = gardenConfig.clients.laptop;
    in {
      enable = true;
      openFirewall = true;

      interfaces = {
        "garden" = {
          addresses = ["${laptopConfig.address}/24"];
          privateKeyFile = "/secrets/wireguard/garden/private";

          peers = lib.singleton {
            publicKey = gardenConfig.server.publicKey;
            endpoint = "${gardenConfig.server.endpoint}:${toString gardenConfig.server.port}";
            allowedIps = ["10.10.10.0/24"];
          };
        };
      };
    };

    hardware = {
      backlight.enable = true;
      bluetooth.enable = true;
      upower.enable = true;
      plymouth.enable = true;

      sound.pipewire.enable = true;

      video = {
        amd.enable = true;
      };
    };

    programs = {
      zsh.enable = true;
      adb.enable = true;
      steam.enable = true;
    };

    virtualisation.docker.enable = true;

    services = {
      gvfs.enable = true;

      syncthing.openFirewall = true;
      kdeconnect.openFirewall = true;
    };

    dm.greetd = {
      enable = true;

      outputs = {
        "eDP-1" = {
          resolution = "1920x1080";
          refreshRate = 60.0;
          background = "${./wallpaper.png} stretch";
        };
      };
    };

    wm.wayland.sway.enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

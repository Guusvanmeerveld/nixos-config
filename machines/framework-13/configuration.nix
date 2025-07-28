{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../../nixos

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];

  boot = {
    tmp = {
      useTmpfs = true;
    };

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };

    kernelParams = ["amdgpu.dcdebugmask=0x10" "pcie_aspm=off"];
  };

  # Custom systemd service that unloads the wifi driver for the wifi card before hibernation and suspend, because they will otherwise fail.
  # This should get fixed in a future kernel update
  systemd.services.unload-wifi-mod-before-sleep = {
    description = "Disable wifi and bluetooth before suspend";
    before = ["hibernate.target" "suspend.target"];
    wantedBy = ["hibernate.target" "suspend.target"];

    serviceConfig = let
      modprobe = "${pkgs.kmod}/bin/modprobe";
    in {
      Type = "oneshot";

      ExecStart = "${modprobe} -r mt7925e";
      ExecStop = "${modprobe} mt7925e";
    };
  };

  hardware.wirelessRegulatoryDatabase = true;

  networking = {
    hostName = "framework-13";
    networkmanager.enable = true;
  };

  services = {
    # BIOS updates are distributed through LVFS, which can be used by enabling the fwupd service
    # From: https://wiki.nixos.org/wiki/Hardware/Framework/Laptop_13
    fwupd = {
      enable = true;

      extraRemotes = ["lvfs-testing"];
    };

    logind = {
      lidSwitch = "hibernate";
    };

    colord.enable = true;
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

    networking.wireguard = {
      enable = true;

      networks = {
        "garden" = {
          enable = true;
        };
      };
    };

    hardware = {
      backlight.enable = true;
      bluetooth.enable = true;
      upower.enable = true;
      plymouth.enable = true;

      sound.pipewire.enable = true;
      video.amd.enable = true;
    };

    alerts = {
      disk-space.enable = true;
    };

    programs = {
      zsh.enable = true;
      adb.enable = true;
      steam.enable = true;
      sudo-rs.enable = true;
    };

    virtualisation.docker.enable = true;

    services = {
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

        caddy.url = "https://syncthing.framework";
        openFirewall = true;
      };

      restic.client.enable = true;
    };

    dm.greetd.enable = true;

    wm.wayland.sway.enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.grub2-themes.nixosModules.default

    ../../nixos/modules

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];

    config = {
      allowUnfree = false;
    };
  };

  networking.hostName = "desktop";

  networking.networkmanager.enable = true;

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    grub = {
      enable = true;

      efiSupport = true;
      useOSProber = true;
      device = "nodev";
    };

    grub2-theme = {
      enable = true;
      theme = "tela";
      icon = "color";
      screen = "ultrawide2k";
      footer = true;
    };
  };

  services.xserver.libinput = {
    mouse = {
      accelProfile = "flat";
      accelSpeed = "-0.25";
    };
  };

  custom = {
    user.name = "guus";

    applications = {
      shell.zsh.enable = true;

      docker.enable = true;

      graphical = {
        steam.enable = true;
      };

      qemu = {
        enable = true;
        graphical = true;
      };
    };

    video.amd.enable = true;

    wm.i3.enable = true;
  };

  networking.firewall.allowedTCPPorts = [22000];
  networking.firewall.allowedUDPPorts = [22000 21027];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

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

    ../modules

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

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;

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
    user = "guus";

    applications = {
      shell.zsh.enable = true;

      docker.enable = true;

      graphical = {
        corsairKeyboard = true;
        steam.enable = true;
      };

      vm = {
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

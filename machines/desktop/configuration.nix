{
  inputs,
  outputs,
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

  # Prevent USB controller from awaking the system from suspend.
  services.udev.extraRules = ''
    ACTION=="add" SUBSYSTEM=="pci" ATTR{vendor}=="0x8086" ATTR{device}=="0x7a60" ATTR{power/wakeup}="disabled"
  '';

  custom = {
    user.name = "guus";

    security.keyring.enable = true;

    applications = {
      shell.zsh.enable = true;

      docker.enable = true;
      android.enable = true;

      graphical = {
        steam.enable = true;

        gtk.enable = true;
        openrgb.enable = true;
      };

      wireguard.openFirewall = true;

      services.syncthing.openFirewall = true;

      qemu = {
        enable = true;
        graphical = true;
      };
    };

    dm.greetd.enable = true;

    wm.wayland = {
      enable = true;

      sway.enable = true;
    };

    pipewire.enable = true;
  };
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

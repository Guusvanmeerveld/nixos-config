{...}: {
  imports = [
    ../../nixos

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  networking.hostName = "vm";

  networking.networkmanager.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.graphics.enable = true;

  custom = {
    user.name = "guus";

    hardware.sound.pipewire.enable = true;

    applications = {
      shell.zsh.enable = true;
    };

    dm.greetd = {
      enable = true;
      outputs = {
        "Virtual-1" = {
          mode = "1920x1080@60Hz";
          bg = "${./wallpaper.jpg} stretch";
        };
      };
    };

    wm.wayland.sway = {
      enable = true;
      useFx = false;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

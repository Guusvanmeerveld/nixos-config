{...}: {
  imports = [
    ../../nixos

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  networking.hostName = "vm";

  networking.networkmanager.enable = true;

  hardware.graphics.enable = true;

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    timeout = 0;
    efi.canTouchEfiVariables = true;
  };

  custom = {
    users."guus" = {
      isSuperUser = true;

      homeManager = {
        enable = true;

        config = ./guus/home.nix;
      };
    };

    hardware.sound.pipewire.enable = true;

    programs = {
      zsh.enable = true;
      sudo-rs.enable = true;
    };

    dm.greetd.enable = true;

    wm.wayland.sway = {
      enable = true;
      useSwayFx = false;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

{...}: {
  imports = [
    ../../nixos/modules

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  networking.hostName = "vm";

  networking.networkmanager.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.opengl.enable = true;

  custom = {
    user.name = "guus";

    applications = {
      shell.zsh.enable = true;
    };

    dm.greetd.enable = true;

    wm.wayland.sway.enable = true;

    pipewire.enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

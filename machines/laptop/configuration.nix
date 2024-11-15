{...}: {
  imports = [
    ../../nixos/modules

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 0;
  };

  networking.hostName = "laptop";

  networking.networkmanager.enable = true;

  services.logind = {
    lidSwitch = "hibernate";
    # powerKeyLongPress = "reboot";
    # powerKey = "poweroff";
  };

  programs.light.enable = true;
  services.power-profiles-daemon.enable = true;

  custom = {
    user.name = "guus";

    security.keyring.enable = true;

    bluetooth.enable = true;

    applications = {
      shell.zsh.enable = true;

      mconnect.enable = true;
      android.enable = true;
      graphical = {
        thunar.enable = true;
        steam.enable = true;
      };

      services = {
        upower.enable = true;

        docker = {
          enable = true;

          vaultwarden.enable = true;
        };
      };

      wireguard.openFirewall = true;
    };

    dm.greetd = {
      enable = true;
      backgroundImage = ./wallpaper.jpg;
    };

    wm.wayland.sway.enable = true;

    pipewire.enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

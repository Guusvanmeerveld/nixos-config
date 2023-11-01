{ pkgs, ...}:

{
  environment = {
    systemPackages = with pkgs; [
       librewolf
       evince
       pavucontrol
    ];
  };

  hardware = {
    pulseaudio.enable = false;
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    thunar = {
      enable = true;
    };
  };

  security.pam.services.gdm.enableGnomeKeyring = true;

  services = {
    gnome.gnome-keyring.enable = true;

    pipewire = {
      enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };

      pulse.enable = true;
    };

    xserver = {
      enable = true;

      layout = "us";
      xkbVariant = "";

      displayManager = {
        autoLogin = {
          enable = true;
          user = "guus";
        };

        lightdm = {
          enable = true;
        };
      };

      desktopManager = {
        xterm.enable = false;

        xfce = {
          enable = true;
        };
      };
    };
  };

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };
}

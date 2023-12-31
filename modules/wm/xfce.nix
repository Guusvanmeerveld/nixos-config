{ pkgs, ... }:

{
  imports = [ ./sound.nix ];

  environment = {
    systemPackages = with pkgs; [
      librewolf
      evince
      pavucontrol
    ];
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
}

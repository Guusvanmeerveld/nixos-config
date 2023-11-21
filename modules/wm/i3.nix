{ config
, pkgs
, ...
}: {
  imports = [ ./sound.nix ];

  security.pam.services.gdm.enableGnomeKeyring = true;

  programs = {
    dconf.enable = true;
    light.enable = true;
  };

  services = {
    gnome.gnome-keyring.enable = true;

    xserver = {
      enable = true;

      desktopManager = {
        xterm.enable = false;
      };

      displayManager = {
        autoLogin = {
          enable = true;
          user = "guus";
        };

        lightdm.enable = true;
      };

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          xorg.xprop
          xcolor
          i3lock-fancy-rapid

          dunst
          flameshot
          rofi
          polybar
          pavucontrol
          playerctl
        ];
      };

    };
  };
}

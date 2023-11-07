{ config
, pkgs
, ...
}: {
  imports = [ ./sound.nix ];

  security.pam.services.gdm.enableGnomeKeyring = true;

  programs.dconf.enable = true;

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
          rofi
          polybar
          xorg.xprop
          xcolor
          i3lock-fancy-rapid
          i3blocks
          killall
          dunst
          pavucontrol
        ];
      };

    };
  };
}

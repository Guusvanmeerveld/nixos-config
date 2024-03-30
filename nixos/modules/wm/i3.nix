{ lib
, config
, pkgs
, ...
}:
let cfg = config.custom.wm.i3; in
{
  imports = [ ../sound.nix ];

  options = {
    custom.wm.i3 =
      {
        enable = lib.mkEnableOption "Enable i3 wm";
      };
  };

  config = lib.mkIf cfg.enable {
    custom.sound.enable = true;

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
            user = config.custom.user;
          };

          lightdm.enable = true;
        };

        windowManager.i3 = {
          enable = true;
        };

      };
    };
  };

}

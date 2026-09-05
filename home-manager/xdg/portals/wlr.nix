{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.xdg.portals.wlr;

  configFile = lib.generators.toINI {} cfg.settings;
in {
  options = {
    custom.xdg.portals.wlr = {
      enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable WLR XDG desktop portal";
        default = config.custom.wm.wayland.sway.enable;
        # default = false;
      };

      settings = lib.mkOption {
        description = ''
          Configuration for `xdg-desktop-portal-wlr`.

          See `xdg-desktop-portal-wlr(5)` for supported
          values.
        '';

        type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
      };
    };
  };

  config = lib.mkIf (cfg.enable && config.custom.xdg.portals.enable) {
    systemd.user.packages = with pkgs; [xdg-desktop-portal-wlr];

    xdg = {
      configFile."xdg-desktop-portal-wlr/config".text = configFile;

      portal = {
        config = {
          common = {
            "org.freedesktop.impl.portal.Screenshot" = "wlr";
            "org.freedesktop.impl.portal.ScreenCast" = "wlr";
          };
        };

        extraPortals = with pkgs; [xdg-desktop-portal-wlr];
      };
    };
  };
}

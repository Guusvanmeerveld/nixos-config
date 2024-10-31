{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.xdg.portals;
in {
  imports = [./wlr.nix];

  options = {
    custom.xdg.portals = {
      enable = lib.mkEnableOption "Enable XDG portals configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg = {
      mimeApps.enable = true;

      portal = {
        enable = true;

        config = {
          common = {
            default = "gtk";

            "org.freedesktop.impl.portal.Screenshot" = "hyprland";
            "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
          };
        };

        # xdgOpenUsePortal = true;

        extraPortals = with pkgs; [xdg-desktop-portal-gtk xdg-desktop-portal-hyprland];
      };
    };
  };
}

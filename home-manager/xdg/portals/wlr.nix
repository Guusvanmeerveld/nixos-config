{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.xdg.portals.wlr;

  settingsFormat = pkgs.formats.ini {};
  configFile = settingsFormat.generate "xdg-desktop-portal-wlr.ini" cfg.settings;

  rofiChooser = pkgs.writeShellApplication {
    name = "rofi-chooser";

    runtimeInputs = with pkgs; [rofi wlr-randr jq];

    text = ''
      displays=$(wlr-randr --json | jq -r 'map(.name) | join(" ")')

      # Check if there are any displays
      if [ -z "$displays" ]; then
          echo "No displays found."
          exit 1
      fi

      # Use Rofi to select a display
      selected_display=$(echo "$displays" | rofi -dmenu -p "Select a display:")

      # Check if a display was selected
      if [ -n "$selected_display" ]; then
          echo "$selected_display"
      else
          echo "No display selected."
          exit 1
      fi
    '';
  };
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

        type = lib.types.submodule {
          freeformType = settingsFormat.type;
        };

        default = {
          screencast = {
            max_fps = 60;
            chooser_type = "simple";
            chooser_cmd = lib.getExe rofiChooser;
          };
        };
      };
    };
  };

  config = lib.mkIf (cfg.enable && config.custom.xdg.portals.enable) {
    systemd.user.services.xdg-desktop-portal-wlr.Service.ExecStart = [
      "${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr --config=${configFile}"
    ];

    xdg = {
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

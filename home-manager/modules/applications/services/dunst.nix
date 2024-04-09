{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.services.dunst;
  theme = config.custom.theme;
in {
  imports = [../../theme];

  options = {
    custom.applications.services.dunst = {
      enable = lib.mkEnableOption "Enable Dunst notification service";
    };
  };

  config = lib.mkIf cfg.enable {
    services.dunst = {
      enable = true;

      settings = {
        global = {
          width = 500;
          height = 300;

          offset = "10x53";
          origin = "top-right";

          transparency = 10;
          frame_width = 1;

          frame_color = theme.background.secondary;
          font = theme.font.name;

          mouse_left = "do_action";
          mouse_middle = "close_current";
          mouse_right = "context";
        };

        urgency_normal = {
          background = theme.background.primary;
          foreground = theme.text.primary;
          timeout = 10;
        };
      };
    };
  };
}

{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.services.dunst;
in {
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

          frame_color = "#${config.colorScheme.palette.base02}";
          font = "Fira Code";

          mouse_left = "do_action";
          mouse_middle = "close_current";
          mouse_right = "context";
        };

        urgency_normal = {
          background = "#${config.colorScheme.palette.base00}";
          foreground = "#${config.colorScheme.palette.base07}";
          timeout = 10;
        };
      };
    };
  };
}

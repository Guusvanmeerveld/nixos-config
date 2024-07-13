{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.notifications.swaync;
  package = pkgs.swaynotificationcenter;
in {
  options = {
    custom.wm.notifications.swaync = {
      enable = lib.mkEnableOption "Enable sway notifaction manager";

      font = lib.mkOption {
        type = lib.types.str;
        # Get the first item from the list and  grab the name attr
        default = builtins.getAttr "name" (builtins.head config.custom.applications.graphical.font.default);
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.swaync = {
      inherit package;

      enable = true;

      settings = {
        layer = "top";

        control-center-margin-top = 20;
        control-center-margin-right = 20;
        control-center-margin-bottom = 20;

        widgets = ["inhibitors" "title" "mpris" "dnd" "notifications"];
      };

      # style = let
      #   bg-color = "#${config.colorScheme.palette.base00}";
      #   alt-bg-color = "#${config.colorScheme.palette.base01}";

      #   font-color = "#${config.colorScheme.palette.base05}";

      #   primary-color = "#${config.colorScheme.palette.base0D}";
      # in '''';
    };
  };
}

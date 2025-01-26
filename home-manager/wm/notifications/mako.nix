{
  lib,
  config,
  ...
}: let
  cfg = config.custom.wm.notifications.mako;
in {
  options = {
    custom.wm.notifications.mako = {
      enable = lib.mkEnableOption "Enable mako notification service";

      font = lib.mkOption {
        type = lib.types.str;
        # Get the first item from the list and  grab the name attr
        default = builtins.getAttr "name" (builtins.head config.custom.programs.theming.font.default);
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.mako = let
      bg-color = "#${config.colorScheme.palette.base00}";
      alt-bg-color = "#${config.colorScheme.palette.base01}";

      font-color = "#${config.colorScheme.palette.base05}";

      primary-color = "#${config.colorScheme.palette.base0D}";
    in {
      enable = true;

      font = "${cfg.font} 12";

      backgroundColor = bg-color;
      textColor = font-color;
      borderColor = alt-bg-color;
      borderRadius = 5;

      progressColor = primary-color;

      margin = "20";

      width = 400;

      defaultTimeout = 10 * 1000;
    };
  };
}

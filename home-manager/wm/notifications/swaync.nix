{
  lib,
  config,
  ...
}: let
  cfg = config.custom.wm.notifications.swaync;
in {
  options = {
    custom.wm.notifications.swaync.enable = lib.mkEnableOption "Enable sway notifaction manager";
  };

  config = lib.mkIf cfg.enable {
    services.swaync = {
      enable = true;

      settings = {
        layer = "top";

        control-center-margin-top = 20;
        control-center-margin-right = 20;
        control-center-margin-bottom = 20;

        widgets = ["inhibitors" "title" "mpris" "dnd" "notifications"];
      };
    };
  };
}

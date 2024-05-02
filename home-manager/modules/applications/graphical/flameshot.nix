{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.graphical.flameshot;
in {
  options = {
    custom.applications.graphical.flameshot = {
      enable = lib.mkEnableOption "Enable Flameshot screenshot program";
    };
  };

  config = lib.mkIf cfg.enable {
    services.flameshot = {
      enable = true;
      settings = {
        General = {
          disabledTrayIcon = true;
          showHelp = false;

          uiColor = "#${config.colorScheme.palette.base0D}";
          contrastUiColor = "#${config.colorScheme.palette.base07}";
        };
      };
    };
  };
}

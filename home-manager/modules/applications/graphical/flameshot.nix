{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.graphical.flameshot;
  theme = config.custom.wm.theme;
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

          uiColor = theme.primary;
          contrastUiColor = theme.text.primary;
        };
      };
    };
  };
}

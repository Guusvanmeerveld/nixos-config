{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.flameshot;
in {
  options = {
    custom.programs.flameshot = {
      enable = lib.mkEnableOption "Enable Flameshot screenshot program";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.applications = [
      {
        inherit (config.services.flameshot) package;
        keybind = "Print";
      }
    ];

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

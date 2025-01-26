{
  lib,
  config,
  pkgs,
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
    custom.programs.defaultApplications.screenshot = {
      name = "flameshot";
      path = "${pkgs.flameshot}/bin/flameshot gui";
      wm-class = "flameshot";
    };

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

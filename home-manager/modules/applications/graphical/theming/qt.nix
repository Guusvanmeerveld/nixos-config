{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.theming.qt;
in {
  options = {
    custom.applications.graphical.theming.qt = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.custom.applications.graphical.theming.enable;
        description = "Enable Qt theming";
      };

      style = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "adwaita-dark";
        };

        package = lib.mkPackageOption pkgs "adwaita-qt" {};
      };
    };
  };

  config = lib.mkIf cfg.enable {
    qt = {
      enable = true;

      platformTheme.name = "awaita";

      style = cfg.style;
    };
  };
}

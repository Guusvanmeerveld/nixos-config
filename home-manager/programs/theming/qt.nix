{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.theming.qt;
in {
  options = {
    custom.programs.theming.qt = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.custom.programs.theming.enable;
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

      platformTheme.name = "qtct";
      style.name = "kvantum";
    };

    xdg.configFile = {
      "Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=WhiteSurDark
      '';

      "Kvantum/WhiteSur".source = "${pkgs.whitesur-kde}/share/Kvantum/WhiteSur";
    };
  };
}

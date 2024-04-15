{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.custom.wm.theme;
in {
  imports = [./gtk.nix];

  options = {
    custom.wm.theme = {
      default.enable = lib.mkEnableOption "Enable default theme options";

      font = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "Fira Code";
          description = "Font name";
        };

        package = lib.mkOption {
          type = with lib.types; nullOr package;
          default = pkgs.fira-code;
          description = "The font package to use";
        };
      };

      background = {
        primary = lib.mkOption {
          type = lib.types.str;
          default = "#151515";
          description = "Primary background color";
        };

        secondary = lib.mkOption {
          type = lib.types.str;
          default = "#212121";
          description = "Secondary background color";
        };

        alt = {
          primary = lib.mkOption {
            type = lib.types.str;
            default = "#232323";
            description = "Primary alt background color";
          };

          secondary = lib.mkOption {
            type = lib.types.str;
            default = "#353535";
            description = "Secondary alt background color";
          };
        };
      };

      text = {
        primary = lib.mkOption {
          type = lib.types.str;
          default = "#eeeeee";
          description = "Primary text color";
        };

        secondary = lib.mkOption {
          type = lib.types.str;
          default = "#cecece";
          description = "Secondary text color";
        };
      };

      ok = lib.mkOption {
        type = lib.types.str;
        default = "#98c379";
        description = "Success color";
      };

      warn = lib.mkOption {
        type = lib.types.str;
        default = "#e06c75";
        description = "Warning color";
      };

      error = lib.mkOption {
        type = lib.types.str;
        default = "#be5046";
        description = "Error color";
      };

      primary = lib.mkOption {
        type = lib.types.str;
        default = "#2997f2";
        description = "Primary color";
      };
    };
  };

  config = lib.mkIf cfg.default.enable {
    home.packages = [cfg.font.package];

    custom.wm.theme.gtk.enable = true;
  };
}

{ lib, config, ... }:
let cfg = config.custom.theme; in
{
  imports = [ ./gtk.nix ];

  options = {
    custom.theme = {
      font = {
        name = lib.mkOption {
          type = lib.types.str;
          description = "Font name";
        };

        package = lib.mkOption {
          type = with lib.types; nullOr package;
          description = "The font package to use";
        };
      };

      background = {
        primary = lib.mkOption {
          type = lib.types.str;
          description = "Primary background color";
        };

        secondary = lib.mkOption {
          type = lib.types.str;
          description = "Secondary background color";
        };

        alt = {
          primary = lib.mkOption {
            type = lib.types.str;
            description = "Primary alt background color";
          };

          secondary = lib.mkOption {
            type = lib.types.str;
            description = "Secondary alt background color";
          };
        };
      };

      text = {
        primary = lib.mkOption {
          type = lib.types.str;
          description = "Primary text color";
        };

        secondary = lib.mkOption {
          type = lib.types.str;
          description = "Secondary text color";
        };
      };

      ok = lib.mkOption {
        type = lib.types.str;
        description = "Success color";
      };

      warn = lib.mkOption {
        type = lib.types.str;
        description = "Warning color";
      };

      error = lib.mkOption {
        type = lib.types.str;
        description = "Error color";
      };

      primary = lib.mkOption {
        type = lib.types.str;
        description = "Primary color";
      };
    };
  };

  config = {
    home.packages = [ cfg.font.package ];
  };
}

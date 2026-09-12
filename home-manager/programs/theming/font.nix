{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.theming.font;
in {
  options = {
    custom.programs.theming.font = let
      defaultFontOptions = config.custom.shared.theming.fonts;
    in {
      enable = lib.mkEnableOption "Enable font theming";

      serif = {
        package = lib.mkOption {
          default = defaultFontOptions.serif.package;
          type = lib.types.package;
        };

        name = lib.mkOption {
          type = lib.types.str;
          description = "The fonts name";

          default = defaultFontOptions.serif.name;
        };
      };

      monospace = {
        package = lib.mkOption {
          type = lib.types.package;
          default = defaultFontOptions.monospace.package;
        };

        name = lib.mkOption {
          type = lib.types.str;
          description = "The fonts name";

          default = defaultFontOptions.monospace.name;
        };
      };

      emoji = {
        package = lib.mkOption {
          default = defaultFontOptions.emoji.package;
          type = lib.types.package;
        };

        name = lib.mkOption {
          type = lib.types.str;
          description = "The fonts name";

          default = defaultFontOptions.emoji.name;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.serif.package cfg.monospace.package];

    fonts.fontconfig = {
      enable = true;

      defaultFonts = {
        serif = [cfg.serif.name];
        sansSerif = [cfg.serif.name];
        monospace = [cfg.monospace.name];
        emoji = [cfg.emoji.name];
      };
    };
  };
}

{
  lib,
  config,
  pkgs,
  shared,
  ...
}: let
  cfg = config.custom.programs.theming.font;
in {
  options = {
    custom.programs.theming.font = let
      defaultFontOptions = shared.theming.font;
    in {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.custom.programs.theming.enable;
        description = "Enable font theming";
      };

      serif = {
        package = lib.mkPackageOption pkgs defaultFontOptions.serif.package {};

        name = lib.mkOption {
          type = lib.types.str;
          description = "The fonts name";

          default = defaultFontOptions.serif.name;
        };
      };

      monospace = {
        package = lib.mkPackageOption pkgs defaultFontOptions.monospace.package {};

        name = lib.mkOption {
          type = lib.types.str;
          description = "The fonts name";

          default = defaultFontOptions.monospace.name;
        };
      };

      emoji = {
        package = lib.mkPackageOption pkgs defaultFontOptions.emoji.package {};

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

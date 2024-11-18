{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.theming.font;
in {
  options = {
    custom.applications.graphical.theming.font = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.custom.applications.graphical.theming.enable;
        description = "Enable font theming";
      };

      serif = {
        package = lib.mkPackageOption pkgs "inter" {};

        name = lib.mkOption {
          type = lib.types.str;
          description = "The fonts name";

          default = "Inter";
        };
      };

      monospace = {
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.nerdfonts.override {fonts = ["FiraCode"];};
        };

        name = lib.mkOption {
          type = lib.types.str;
          description = "The fonts name";

          default = "FiraCode Nerd Font Mono";
        };
      };

      emoji = {
        package = lib.mkPackageOption pkgs "noto-fonts-color-emoji" {};

        name = lib.mkOption {
          type = lib.types.str;
          description = "The fonts name";

          default = "NotoColorEmoji";
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

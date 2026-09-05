{
  pkgs,
  lib,
  config,
  shared,
  ...
}: let
  cfg = config.custom.programs.theming.default-apps;
in {
  options.custom.programs.theming.default-apps = {
    enable = lib.mkEnableOption "Enable default theming options";

    cursor = let
      defaultCursorOptions = shared.theming.cursor;
    in {
      name = lib.mkOption {
        type = lib.types.str;
        default = defaultCursorOptions.name;
      };

      package = lib.mkPackageOption pkgs defaultCursorOptions.package {};
    };
  };

  config = lib.mkIf cfg.enable {
    custom.programs.theming = {
      gtk.enable = lib.mkDefault true;
      qt.enable = lib.mkDefault true;
      font.enable = lib.mkDefault true;
    };

    home.pointerCursor = {
      enable = true;

      inherit (cfg.cursor) name;
      inherit (cfg.cursor) package;

      size = 24;

      gtk.enable = true;
    };
  };
}

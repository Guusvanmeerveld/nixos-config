{
  pkgs,
  lib,
  config,
  shared,
  ...
}: let
  cfg = config.custom.applications.graphical.theming;
in {
  imports = [
    ./font.nix
    ./gtk.nix
    ./qt.nix
  ];

  options = {
    custom.applications.graphical.theming = {
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
  };

  config = lib.mkIf cfg.enable {
    allowedUnfree = ["apple_cursor"];

    home.pointerCursor = {
      name = cfg.cursor.name;
      package = cfg.cursor.package;

      size = 24;

      gtk.enable = true;
    };
  };
}

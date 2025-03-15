{
  pkgs,
  lib,
  config,
  shared,
  ...
}: let
  cfg = config.custom.programs.theming;
in {
  imports = [
    ./font.nix
    ./gtk.nix
    ./qt.nix
  ];

  options = {
    custom.programs.theming = {
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
    home.pointerCursor = {
      inherit (cfg.cursor) name;
      inherit (cfg.cursor) package;

      size = 24;

      gtk.enable = true;
    };
  };
}

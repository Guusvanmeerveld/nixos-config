{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.graphical.theming;
in {
  imports = [
    ./font.nix
    ./gtk.nix
  ];

  options = {
    custom.applications.graphical.theming = {
      enable = lib.mkEnableOption "Enable default theming options";

      cursor = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "macOS-BigSur";
        };

        package = lib.mkPackageOption pkgs "apple-cursor" {};
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.pointerCursor = {
      name = cfg.cursor.name;
      package = cfg.cursor.package;

      size = 20;

      gtk.enable = true;
    };
  };
}

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
    };
  };

  config = lib.mkIf cfg.enable {
    custom.applications.graphical.theming = {
      font.enable = true;
      gtk.enable = true;
    };

    home.pointerCursor = {
      name = "macOS-BigSur";
      package = pkgs.apple-cursor;

      size = 20;

      gtk.enable = true;
    };
  };
}

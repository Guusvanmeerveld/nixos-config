{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.games.scarab;
in {
  options = {
    custom.applications.graphical.games.scarab = {
      enable = lib.mkEnableOption "Enable Scarab Hollow Knight mod manager";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [scarab];
  };
}

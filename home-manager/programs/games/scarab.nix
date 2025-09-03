{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.games.scarab;
in {
  options = {
    custom.programs.games.scarab = {
      enable = lib.mkEnableOption "Enable Scarab Hollow Knight mod manager";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [lumafly];
  };
}

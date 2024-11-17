{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.games.heroic;
in {
  options = {
    custom.applications.graphical.games.heroic = {
      enable = lib.mkEnableOption "Enable Heroic games launcher";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [heroic];
  };
}

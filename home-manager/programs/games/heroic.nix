{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.games.heroic;
in {
  options = {
    custom.programs.games.heroic = {
      enable = lib.mkEnableOption "Enable Heroic games launcher";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      protonup
      heroic
    ];
  };
}

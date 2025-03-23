{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.missioncenter;
in {
  options = {
    custom.programs.missioncenter = {
      enable = lib.mkEnableOption "Enable Mission center system monitor";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      mission-center
    ];
  };
}

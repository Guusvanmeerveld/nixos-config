{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.development.digital;
in {
  options = {
    custom.programs.development.digital = {
      enable = lib.mkEnableOption "Enable Digital logic designer and circuit simulator";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [digital];
  };
}

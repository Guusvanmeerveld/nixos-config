{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.development.digital;
in {
  options = {
    custom.applications.graphical.development.digital = {
      enable = lib.mkEnableOption "Enable Digital logic designer and circuit simulator";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [digital];
  };
}

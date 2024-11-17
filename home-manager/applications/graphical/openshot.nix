{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.openshot;
in {
  options = {
    custom.applications.graphical.openshot = {
      enable = lib.mkEnableOption "Enable Openshot video editing software";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [openshot-qt];
  };
}

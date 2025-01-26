{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.openshot;
in {
  options = {
    custom.programs.openshot = {
      enable = lib.mkEnableOption "Enable Openshot video editing software";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [openshot-qt];
  };
}

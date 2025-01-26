{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.office.gimp;
in {
  options = {
    custom.programs.office.gimp = {
      enable = lib.mkEnableOption "Enable Gnu Image Manipulation Program";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [gimp];
  };
}

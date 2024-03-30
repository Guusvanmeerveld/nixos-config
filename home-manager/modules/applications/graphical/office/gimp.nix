{ lib, config, pkgs, ... }:
let cfg = config.custom.applications.graphical.office.gimp; in
{
  options = {
    custom.applications.graphical.office.gimp = {
      enable = lib.mkEnableOption "Enable Gnu Image Manipulation Program";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ gimp ];
  };
}


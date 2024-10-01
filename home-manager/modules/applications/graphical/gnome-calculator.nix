{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.gnome-calculator;
in {
  options = {
    custom.applications.graphical.gnome-calculator = {
      enable = lib.mkEnableOption "Enable Gnome calculator application";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gnome.gnome-calculator
    ];
  };
}

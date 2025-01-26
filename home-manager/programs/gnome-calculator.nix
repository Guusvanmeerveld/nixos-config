{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.gnome-calculator;
in {
  options = {
    custom.programs.gnome-calculator = {
      enable = lib.mkEnableOption "Enable Gnome calculator application";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gnome-calculator
    ];
  };
}

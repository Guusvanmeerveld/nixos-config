{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.cheese;
in {
  options = {
    custom.programs.cheese = {
      enable = lib.mkEnableOption "Enable Cheese camera application";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [cheese];
  };
}

{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.development.utils;
in {
  options = {
    custom.applications.development.utils = {
      enable = lib.mkEnableOption "Enable development utils";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [duckdb custom.radb];
  };
}

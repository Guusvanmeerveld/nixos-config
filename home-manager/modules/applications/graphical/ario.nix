{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.ario;
in {
  options = {
    custom.applications.graphical.ario = {
      enable = lib.mkEnableOption "Enable Ario MPD client";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ario
    ];
  };
}

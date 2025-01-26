{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.ario;
in {
  options = {
    custom.programs.ario = {
      enable = lib.mkEnableOption "Enable Ario MPD client";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ario
    ];
  };
}

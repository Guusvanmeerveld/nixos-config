{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.messaging.fractal;
in {
  options = {
    custom.programs.messaging.fractal = {
      enable = lib.mkEnableOption "Enable Fractal Matrix client";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      fractal
    ];
  };
}

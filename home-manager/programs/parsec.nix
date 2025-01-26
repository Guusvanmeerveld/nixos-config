{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.parsec;
in {
  options = {
    custom.programs.parsec = {
      enable = lib.mkEnableOption "Enable Parsec remote streaming program";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [parsec-bin];
  };
}

{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.development.unity;
in {
  options = {
    custom.programs.development.unity = {
      enable = lib.mkEnableOption "Enable Unity hub";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [unityhub ffmpeg];
  };
}

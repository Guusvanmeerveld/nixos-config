{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.teamviewer;
in {
  options = {
    custom.programs.teamviewer = {
      enable = lib.mkEnableOption "Enable TeamViewer remote desktop interface";
    };
  };

  config = lib.mkIf cfg.enable {
    services.teamviewer = {
      enable = true;
    };
  };
}

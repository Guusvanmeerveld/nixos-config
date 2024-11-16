{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.graphical.teamviewer;
in {
  options = {
    custom.applications.graphical.teamviewer = {
      enable = lib.mkEnableOption "Enable TeamViewer remote desktop interface";
    };
  };

  config = lib.mkIf cfg.enable {
    services.teamviewer = {
      enable = true;
    };

    allowedUnfree = ["teamviewer"];
  };
}

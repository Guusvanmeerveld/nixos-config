{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.evince;
in {
  options = {
    custom.applications.graphical.evince = {
      enable = lib.mkEnableOption "Enable Evince PDF reader program";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [evince];

    xdg.mimeApps = {
      defaultApplications = {
        "application/pdf" = ["org.gnome.Evince.desktop"];
      };
    };
  };
}

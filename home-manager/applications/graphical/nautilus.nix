{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.nautilus;

  package = pkgs.gnome.nautilus;
in {
  options = {
    custom.applications.graphical.nautilus = {
      enable = lib.mkEnableOption "Enable Nautilus file explorer";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.applications.graphical.defaultApplications.file-explorer = {
      name = "nautilus";
      path = lib.getExe package;
      wm-class = "Nautilus";
    };

    home.packages = [
      package
    ];

    xdg.mimeApps.defaultApplications = {
      "inode/directory" = ["org.gnome.Nautilus.desktop"];
    };
  };
}

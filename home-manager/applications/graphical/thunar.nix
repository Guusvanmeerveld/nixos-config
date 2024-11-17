{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.thunar;

  plugins = with pkgs.xfce; [thunar-archive-plugin thunar-volman];
  package = pkgs.xfce.thunar.override {thunarPlugins = plugins;};
in {
  options = {
    custom.applications.graphical.thunar = {
      enable = lib.mkEnableOption "Enable Thunar file explorer";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.applications.graphical.defaultApplications.file-explorer = {
      name = "thunar";
      path = "${package}/bin/thunar";
      wm-class = "Thunar";
    };

    home.packages = [
      package
    ];

    xdg.mimeApps.defaultApplications = {
      "inode/directory" = ["thunar.desktop"];
    };
  };
}

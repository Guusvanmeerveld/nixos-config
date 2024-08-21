{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.thunar;

  plugins = with pkgs.xfce; [thunar-archive-plugin thunar-volman];
  thunar = pkgs.xfce.thunar.override {thunarPlugins = plugins;};
in {
  options = {
    custom.applications.graphical.thunar = {
      enable = lib.mkEnableOption "Enable Thunar file explorer";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.applications.graphical.defaultApplications.file-explorer = {
      name = "thunar";
      path = "${thunar}/bin/thunar";
      wm-class = "Thunar";
    };

    home.packages = [
      thunar
    ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = ["thunar.desktop"];
      };
    };
  };
}

{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.thunar;

  plugins = with pkgs.xfce; [thunar-archive-plugin thunar-volman];
  package = pkgs.xfce.thunar.override {thunarPlugins = plugins;};
in {
  options = {
    custom.programs.thunar = {
      enable = lib.mkEnableOption "Enable Thunar file explorer";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.programs.defaultApplications.file-explorer = {
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

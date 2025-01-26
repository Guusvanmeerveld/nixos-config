{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.nautilus;

  package = pkgs.nautilus;
in {
  options = {
    custom.programs.nautilus = {
      enable = lib.mkEnableOption "Enable Nautilus file explorer";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.programs.defaultApplications.file-explorer = {
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

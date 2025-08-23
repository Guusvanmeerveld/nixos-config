{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.lockscreens.gtklock;

  package = pkgs.gtklock;
in {
  options = {
    custom.wm.lockscreens.gtklock = {
      enable = lib.mkEnableOption "Enable GTK lock screen";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.lockscreens.default = {
      keybind = "$mod+0";
      executable = lib.getExe package;
    };

    home.packages = [package];
  };
}

{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.lockscreens.gtklock;
in {
  options = {
    custom.wm.lockscreens.gtklock = {
      enable = lib.mkEnableOption "Enable GTK lock screen";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.gtklock = {
      enable = true;

      modules = with pkgs; [
        gtklock-playerctl-module
        gtklock-powerbar-module
        gtklock-userinfo-module
      ];
    };
  };
}

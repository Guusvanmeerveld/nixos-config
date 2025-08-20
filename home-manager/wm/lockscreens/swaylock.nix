{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.lockscreens.swaylock;

  package = pkgs.swaylock-fancy;
in {
  options = {
    custom.wm.lockscreens.swaylock = {
      enable = lib.mkEnableOption "Enable swaylock lock screen";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.lockscreens.default = {
      keybind = "$mod+0";
      executable = lib.getExe package;
    };

    programs.swaylock = {
      inherit package;

      enable = true;
    };
  };
}

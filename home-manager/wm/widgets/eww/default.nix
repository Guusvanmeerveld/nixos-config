{
  lib,
  config,
  ...
}: let
  cfg = config.custom.wm.widgets.eww;
in {
  options = {
    custom.wm.widgets.eww = {
      enable = lib.mkEnableOption "Enable ElKowars wacky widgets";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.eww = {
      enable = true;

      configDir = ./widgets;
    };
  };
}

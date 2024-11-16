{
  lib,
  config,
  ...
}: let
  cfg = config.custom.hardware.backlight;
in {
  options = {
    custom.hardware.backlight = {
      enable = lib.mkEnableOption "Enable Screen backlight control";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.light.enable = true;
  };
}

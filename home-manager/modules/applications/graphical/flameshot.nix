{ lib, config, ... }:
let cfg = config.custom.applications.graphical.flameshot; in
{
  options = {
    custom.applications.graphical.flameshot = {
      enable = lib.mkEnableOption "Enable Flameshot screenshot program";
    };
  };

  config = lib.mkIf cfg.enable {
    services.flameshot = {
      enable = true;
    };
  };
}

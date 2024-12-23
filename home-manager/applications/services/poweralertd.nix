{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.services.poweralertd;
in {
  options = {
    custom.applications.services.poweralertd = {
      enable = lib.mkEnableOption "Enable Power Alert daemon, providing power notifications when needed";
    };
  };

  config = lib.mkIf cfg.enable {
    services.poweralertd.enable = true;
  };
}

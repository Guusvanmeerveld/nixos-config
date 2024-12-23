{
  lib,
  config,
  outputs,
  ...
}: let
  cfg = config.custom.applications.services.updater;
in {
  imports = [outputs.homeManagerModules.updater];

  options = {
    custom.applications.services.updater = {
      enable = lib.mkEnableOption "Enable Home-Manager updating service";
    };
  };

  config = lib.mkIf cfg.enable {
    services.autoUpdate.enable = true;
  };
}

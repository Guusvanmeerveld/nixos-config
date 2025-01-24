{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.invidious;
in {
  options = {
    custom.services.invidious = {
      enable = lib.mkEnableOption "Enable Invidious YouTube frontend";

      port = lib.mkOption {
        type = lib.types.int;
        description = "The port to run the service on";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        description = "The external domain the service can be reached from";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      invidious = {
        enable = true;

        port = cfg.port;

        domain = cfg.domain;

        nginx.enable = true;

        settings = {
          registration_enabled = false;
        };
      };
    };
  };
}

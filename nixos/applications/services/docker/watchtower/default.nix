{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.services.docker.watchtower;
in {
  options = {
    custom.applications.services.docker.watchtower = {
      enable = lib.mkEnableOption "Enable watchtower docker service";

      schedule = lib.mkOption {
        type = lib.types.str;
        default = "@daily";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.docker-compose.projects."watchtower" = {
      file = ./docker-compose.yaml;

      env = {
        SCHEDULE = cfg.schedule;
      };
    };
  };
}

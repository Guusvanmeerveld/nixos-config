{ lib, config, ... }: let cfg = config.custom.applications.services.docker.watchtower; in {
     options = {
        custom.applications.services.docker.watchtower = {
            enable = lib.mkEnableOption "Enable watchtower docker service";
        };
    };

    config = lib.mkIf cfg.enable {
        services.docker-compose.services = [
            {
                name = "watchtower";
                file = ./docker-compose.yaml;
            }
        ];
    };
} 
{ lib, config, ... }: let cfg = config.custom.applications.services.docker.dashdot; in {
     options = {
        custom.applications.services.docker.dashdot = {
            enable = lib.mkEnableOption "Enable dashdot monitoring dashboard";
        };
    };

    config = lib.mkIf cfg.enable {
        services.docker-compose.projects."dashdot" = {
            file = ./docker-compose.yaml;
            
            env = {
                VERSION = "latest";
            };
        };
    };
} 
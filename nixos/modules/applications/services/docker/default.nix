{ inputs, lib, config, ... }: let cfg = config.custom.applications.services.docker; in {
    imports = [
        inputs.docker-compose-nix.nixosModules.default

        ./watchtower
    ];

    options = {
        custom.applications.services.docker = {
            enable = lib.mkEnableOption "Enable docker compose services";
        };
    };

    config = lib.mkIf cfg.enable {
        services.docker-compose.enable = true;
    };
}
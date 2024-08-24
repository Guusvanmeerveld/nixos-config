{ inputs, lib, config, ... }: let cfg = config.custom.applications.services.docker; in {
    imports = [
        inputs.docker-compose-nix.nixosModules.default

        ./watchtower
        ./dashdot
    ];

    options = {
        custom.applications.services.docker = {
            enable = lib.mkEnableOption "Enable docker compose services";
        };
    };

    config = lib.mkIf cfg.enable {
        services.docker-compose.enable = true;

        virtualisation.docker = {
            enable = true;
            autoPrune = {
                enable = true;
            };
        };

        environment.systemPackages = with pkgs; [ctop];
    };
}
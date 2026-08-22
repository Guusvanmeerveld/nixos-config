{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.virtualisation.podman;
in {
  options = {
    custom.virtualisation.podman = {
      enable = lib.mkEnableOption "Enable Podman";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation = {
      podman = {
        enable = true;

        dockerCompat = true;
        autoPrune.enable = true;
      };

      containers.enable = true;
    };

    environment = {
      sessionVariables = {
        PODMAN_COMPOSE_PROVIDER = lib.getExe pkgs.docker-compose;
      };

      systemPackages = with pkgs; [ctop];
    };
  };
}

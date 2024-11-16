{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.services.docker;
in {
  imports = [
    inputs.docker-compose-nix.nixosModules.default

    ./networking.nix
    ./storage.nix

    ./watchtower
    ./dashdot
    ./syncthing
    ./jellyfin
    ./uptime-kuma
    ./caddy
    ./ntfy
    ./gitea
    ./nextcloud
    ./drone
    ./homeassistant
    ./immich
    ./portfolio
    ./qbittorrent
    ./gluetun
    ./searxng
    ./twitch-miner
    ./feg
    ./servarr
    ./vaultwarden
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

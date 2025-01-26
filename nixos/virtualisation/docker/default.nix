{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.virtualisation.docker;
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
    ./unifi
  ];

  options = {
    custom.virtualisation.docker = {
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

    custom.usersGlobalGroups = ["docker"];
  };
}

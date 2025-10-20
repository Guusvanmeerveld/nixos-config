{
  outputs,
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.qbittorrent;
in {
  imports = [
    outputs.nixosModules.qbittorrent-nox
  ];

  options = {
    custom.services.qbittorrent = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable qBittorrent";

      webUIPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 4545;
        description = "The port to run the web ui on";
      };

      saveDir = mkOption {
        type = types.path;
        default = "/var/lib/qbittorrent/downloads";
        description = ''
          The directory where qBittorrent stores its data files.
        '';
      };

      openFirewall = mkOption {
        type = types.bool;
        default = cfg.enable;
        description = "Open qBittorrent ports in firewall";
      };

      caddy.url = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "The external domain the service can be reached from";
      };
    };
  };

  config = let
    inherit (lib) mkIf optionals;
  in
    mkIf cfg.enable {
      networking.firewall.allowedUDPPorts = optionals cfg.openFirewall [config.services.qbittorrent-nox.torrentPort];

      custom.services.restic.client.backups.qbittorrent = {
        services = ["qbittorrent-nox"];

        files = [
          "/var/lib/qbittorrent"
        ];
      };

      services = {
        caddy = mkIf (cfg.caddy.url != null) {
          virtualHosts = {
            "${cfg.caddy.url}" = let
              address =
                if config.services.qbittorrent-nox.address != null
                then config.services.qbittorrent-nox.address
                else "localhost";
            in {
              extraConfig = ''
                reverse_proxy http://${address}:${toString cfg.webUIPort}
                tls internal
              '';
            };
          };
        };

        qbittorrent-nox = {
          enable = true;

          inherit (cfg) webUIPort saveDir;

          theme = "vuetorrent";
        };
      };
    };
}

{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.adguard;
in {
  options = {
    custom.services.adguard = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the Adguard service";

      openFirewall = mkEnableOption "Open the default ports";

      port = mkOption {
        type = types.ints.u16;
        default = 8010;
        description = "The port to run the service on";
      };

      caddy.url = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "The external domain the service can be reached from";
      };
    };
  };

  config = let
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      networking.firewall = {
        allowedTCPPorts = lib.optional cfg.openFirewall 53;
        allowedUDPPorts = lib.optional cfg.openFirewall 53;
      };

      custom.services.restic.client.backups.adguard = {
        files = [
          "/var/lib/AdGuardHome/data"
        ];
      };

      services = {
        caddy = mkIf (cfg.caddy.url != null) {
          virtualHosts = {
            "${cfg.caddy.url}" = {
              extraConfig = ''
                reverse_proxy http://localhost:${toString cfg.port}
              '';
            };
          };
        };

        adguardhome = {
          enable = true;

          inherit (cfg) port;

          mutableSettings = false;

          settings = {
            filtering.blocked_response_ttl = 60 * 60;

            statistics = {
              enabled = true;

              interval = "720h";
            };
          };
        };
      };
    };
}

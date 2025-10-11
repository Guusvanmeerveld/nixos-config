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
        services = ["adguardhome"];

        files = [
          "/var/lib/AdGuardHome/data"
        ];
      };

      networking.hosts = {
        # Required since we would be unable to query the DNS server if it is offline during backups
        "10.10.10.10" = ["restic.chd"];
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
            dns = {
              bootstrap_dns = ["1.1.1.1"];
            };

            statistics = {
              enabled = true;

              interval = "720h";
            };
          };
        };
      };
    };
}

{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.services.unifi;
in {
  options = {
    custom.services.unifi = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the Unifi service";

      port = mkOption {
        type = types.ints.u16;
        default = 8443;
        description = "The port to run the service on";
      };

      openFirewall = mkEnableOption "Open default firewall ports";

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
      custom.services.restic.client.backups.unifi = {
        services = ["unifi"];

        files = [
          "/var/lib/unifi"
        ];
      };

      services = {
        caddy = mkIf (cfg.caddy.url != null) {
          virtualHosts = {
            "${cfg.caddy.url}" = {
              extraConfig = ''
                reverse_proxy https://localhost:${toString cfg.port} {
                  transport http {
                    tls_insecure_skip_verify  # we don't verify the controller https cert
                  }

                  header_up - Authorization  # sets header to be passed to the controller
                }


              '';
            };
          };
        };

        unifi = {
          enable = true;

          inherit (cfg) openFirewall;

          unifiPackage = pkgs.unifi;
          mongodbPackage = pkgs.mongodb;
        };
      };
    };
}

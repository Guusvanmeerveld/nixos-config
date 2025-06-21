{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.caddy;
in {
  options = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    custom.services.caddy = {
      enable = mkEnableOption "Enable Caddy web server";

      openFirewall = mkEnableOption "Open Caddy ports in firewall";

      ca = {
        enable = mkEnableOption "Configure local CA certificates";

        cert = mkOption {
          type = types.path;
          default = "/secrets/caddy/ca/root.crt";
          description = "The root certificate for this CA";
        };

        key = mkOption {
          type = types.path;
          default = "/secrets/caddy/ca/root.key";
          description = "The root key for this CA";
        };
      };
    };
  };

  config = let
    inherit (lib) mkIf optionals;
  in
    mkIf cfg.enable {
      services.caddy = {
        enable = true;

        globalConfig = mkIf cfg.ca.enable ''
          {
          	pki {
          		ca local {
          			name "Local CA"

                root {
                  cert ${cfg.ca.cert}
                  key ${cfg.ca.key}
                }
          		}
          	}
          }
        '';
      };

      networking.firewall.allowedTCPPorts = optionals cfg.openFirewall [80 443];
    };
}

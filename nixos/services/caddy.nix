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

      ipFilter = {
        enable = mkEnableOption "Enable ip blocking";

        whitelist = mkOption {
          type = types.listOf types.str;
          default = ["10.10.10.0/24"];
          description = "List of ip ranges that are allowed to connect to Caddy";
        };

        vHosts = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Virtual hosts that this filter should be enabled for";
        };
      };

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
    inherit (lib) mkIf optionals concatStringsSep optionalString listToAttrs;
  in
    mkIf cfg.enable {
      services.caddy = {
        enable = true;

        # Does not work if admin page is off, so we disable it.
        enableReload = false;

        email = "caddy@guusvanmeerveld.dev";

        virtualHosts = let
          blockIps = ''
            @blocked not remote_ip ${concatStringsSep " " cfg.ipFilter.whitelist}
            respond @blocked "Access Denied" 403
          '';
        in
          mkIf cfg.ipFilter.enable (listToAttrs (map (vHost: {
              name = vHost;
              value = {
                extraConfig = blockIps;
              };
            })
            cfg.ipFilter.vHosts));

        globalConfig = concatStringsSep "\n" [
          ''
            # Disable admin page on port 2019
            admin off
          ''
          (optionalString cfg.ca.enable ''
            pki {
              ca local {
                name "Local CA"

                root {
                  cert ${cfg.ca.cert}
                  key ${cfg.ca.key}
                }
              }
            }
          '')
        ];
      };

      networking.firewall.allowedTCPPorts = optionals cfg.openFirewall [80 443];
    };
}

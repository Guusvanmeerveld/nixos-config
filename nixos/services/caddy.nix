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

        virtualHosts = mkOption {
          type = types.listOf (types.submodule (_: {
            options = {
              whitelist = mkOption {
                type = types.listOf types.str;
                default = [];
                description = "List of IP's that are allowed to access this domain";
              };

              domain = mkOption {
                type = types.str;
                description = "The domain that the ip filter should be enabled for";
              };
            };
          }));

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
    inherit (lib) mkIf optionals optionalString;
  in
    mkIf cfg.enable {
      services.caddy = {
        enable = true;

        # Does not work if admin page is off, so we disable it.
        enableReload = false;

        email = "caddy@guusvanmeerveld.dev";

        virtualHosts = mkIf cfg.ipFilter.enable (builtins.listToAttrs (map ({
            domain,
            whitelist,
          }: {
            name = domain;
            value = {
              extraConfig = ''
                @blocked not remote_ip ${builtins.concatStringsSep " " whitelist}

                handle @blocked {
                  abort
                }
              '';
            };
          })
          cfg.ipFilter.virtualHosts));

        globalConfig = builtins.concatStringsSep "\n" [
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

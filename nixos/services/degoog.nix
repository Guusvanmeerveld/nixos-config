{
  config,
  lib,
  outputs,
  ...
}: let
  cfg = config.custom.services.degoog;
in {
  imports = [
    outputs.nixosModules.degoog
  ];

  options = {
    custom.services.degoog = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable Degoog, a Search engine aggregator with a comprehensive plugin/extension system";

      port = mkOption {
        type = types.ints.u16;
        default = 8999;
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
      custom.services.restic.client.backups.degoog = {
        files = [
          "/var/lib/degoog"
        ];
      };

      services = {
        caddy = mkIf (cfg.caddy.url != null) {
          virtualHosts = {
            ${cfg.caddy.url} = {
              extraConfig = ''
                reverse_proxy http://localhost:${toString cfg.port}
              '';
            };
          };
        };

        degoog = {
          enable = true;

          inherit (cfg) port;

          environmentFile = "/secrets/degoog/environmentFile";
        };
      };
    };
}

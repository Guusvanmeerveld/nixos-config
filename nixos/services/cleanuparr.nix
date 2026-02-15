{
  config,
  outputs,
  lib,
  ...
}: let
  cfg = config.custom.services.cleanuparr;
in {
  imports = [outputs.nixosModules.cleanuparr];

  options = {
    custom.services.cleanuparr = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable cleanuparr";

      port = lib.mkOption {
        type = lib.types.ints.u16;
        default = 11011;
        description = "The port to run the web ui on";
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
      custom.services.restic.client.backups.cleanuparr = {
        services = ["cleanuparr"];

        files = [
          config.services.cleanuparr.dataDir
        ];

        excluded = [
          "logs*"
          "wwwroot"
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

        cleanuparr = {
          enable = true;

          port = cfg.port;
        };
      };
    };
}

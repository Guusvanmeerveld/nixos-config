{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.prowlarr;
in {
  options = {
    custom.services.prowlarr = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable Prowlarr";

      port = lib.mkOption {
        type = lib.types.ints.u16;
        default = 7878;
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
      custom.services.restic.client.backups.prowlarr = {
        services = ["prowlarr"];

        files = [
          config.services.prowlarr.dataDir
        ];

        excluded = [
          "logs*"
        ];
      };

      users.users.prowlarr = {
        group = "prowlarr";
        isSystemUser = true;
      };

      users.groups.prowlarr = {};

      systemd.services.prowlarr.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "prowlarr";
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

        flaresolverr.enable = true;

        prowlarr = {
          enable = true;

          settings = {
            server.port = cfg.port;
          };
        };
      };
    };
}

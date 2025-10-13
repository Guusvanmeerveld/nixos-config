{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.immich;
in {
  options = {
    custom.services.immich = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the Immich service";

      port = mkOption {
        type = types.ints.u16;
        default = 2283;
        description = "The port to run the service on";
      };

      mediaDir = mkOption {
        type = types.str;
        default = "/var/lib/immich";
        description = "Where to store the media";
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
      custom.services.restic.client.backups.immich = {
        postgresDBs = [
          {
            dbName = "immich";
            user = "immich";
          }
        ];
      };

      users.users.immich = {
        uid = 6677;
      };

      users.groups.immich = {
        gid = 6677;
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

        immich = {
          enable = true;

          inherit (cfg) port;

          accelerationDevices = [
            "/dev/dri/renderD128"
          ];

          mediaLocation = cfg.mediaDir;

          settings = {
            server.externalDomain = cfg.caddy.url;

            ffmpeg = {
              accel = "vaapi";
              accelDecode = true;
            };

            storageTemplate = {
              enabled = true;
              hashVerificationEnabled = true;
              template = "{{y}}/{{y}}-{{MM}}-{{dd}}/{{filename}}";
            };
          };
        };
      };
    };
}

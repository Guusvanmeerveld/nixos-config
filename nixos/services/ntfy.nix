{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.ntfy;

  storageDir = "/var/lib/ntfy-sh";
  authFile = "${storageDir}/user.db";
  attachementsCache = "${storageDir}/attachments";
  cacheFile = "${storageDir}/cache-file.db";
in {
  options = {
    custom.services.ntfy = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the Ntfy service";

      isPubliclyAccessible = mkEnableOption "Whether this instance is expected to be accessable by the internet";

      port = mkOption {
        type = types.ints.u16;
        default = 3333;
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
      custom.services.restic.client.backups.ntfy = {
        services = ["ntfy-sh"];

        files = [
          authFile
          attachementsCache
          cacheFile
        ];
      };

      systemd.services.ntfy-sh.serviceConfig = {
        DynamicUser = lib.mkForce false;
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

        ntfy-sh = {
          enable = true;

          settings = {
            listen-http = ":${toString cfg.port}";

            base-url =
              if cfg.caddy.url != null
              then cfg.caddy.url
              else null;
            behind-proxy = cfg.caddy.url != null;
            # Disable signups if publicly available
            enable-signup = !cfg.isPubliclyAccessible;
            auth-default-access =
              if cfg.isPubliclyAccessible
              then "write-only"
              else "read-write";
            enable-login = true;

            auth-file = authFile;
            attachment-cache-dir = attachementsCache;
            cache-file = cacheFile;
          };
        };
      };
    };
}

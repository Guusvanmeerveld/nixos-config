{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.forgejo;
in {
  options = {
    custom.services.forgejo = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable Forgejo, an alternative git server";

      largeStorageDir = mkOption {
        type = types.str;
        description = "Where to store potentially large files related to git";
      };

      port = mkOption {
        type = types.ints.u16;
        default = 8060;
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
      services = {
        caddy = mkIf (cfg.caddy.url != null) {
          virtualHosts = {
            "${cfg.caddy.url}" = {
              extraConfig = ''
                reverse_proxy http://localhost:${toString cfg.port}
                tls internal
              '';
            };
          };
        };

        forgejo = {
          enable = true;

          lfs = {
            enable = true;

            contentDir = "${cfg.largeStorageDir}/lfs";
          };

          database = {
            type = "postgres";
          };

          repositoryRoot = "${cfg.largeStorageDir}/repositories";

          settings = {
            server = {
              ROOT_URL = cfg.caddy.url;
              HTTP_PORT = cfg.port;
            };

            actions = {
              ENABLED = true;
              DEFAULT_ACTIONS_URL = "github";
            };
          };
        };
      };
    };
}

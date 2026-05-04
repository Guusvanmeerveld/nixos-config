{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.seerr;
in {
  options = {
    custom.services.seerr = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the Seerr service";

      port = mkOption {
        type = types.ints.u16;
        default = 8097;
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
      custom.services.restic.client.backups.seerr = {
        services = ["seerr"];

        files = [
          "${config.services.seerr.configDir}/settings.json"
          "${config.services.seerr.configDir}/db"
        ];
      };

      users.users.seerr = {
        group = "seerr";
        isSystemUser = true;
      };

      users.groups.seerr = {};

      systemd.services.seerr.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "seerr";
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

        seerr = {
          enable = true;

          inherit (cfg) port;
        };
      };
    };
}

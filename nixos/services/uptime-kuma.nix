{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.uptime-kuma;
in {
  options = {
    custom.services.uptime-kuma = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the Uptime Kuma service";

      port = mkOption {
        type = types.ints.u16;
        default = 4444;
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
      custom.services.restic.client.backups.uptime-kuma = {
        services = ["uptime-kuma"];

        files = [
          config.services.uptime-kuma.settings.DATA_DIR
        ];
      };

      users.users.uptime-kuma = {
        group = "uptime-kuma";
        isSystemUser = true;
      };

      users.groups.uptime-kuma = {};

      # Disable dynamic user since it prevents even the root user from accessing the files.
      systemd.services.uptime-kuma.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "uptime-kuma";
      };

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

        uptime-kuma = {
          enable = true;

          appriseSupport = true;

          settings = {
            PORT = toString cfg.port;
          };
        };
      };
    };
}

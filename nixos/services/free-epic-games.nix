{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.services.free-epic-games;
in {
  options = {
    custom.services.free-epic-games = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the Free Epic Games service";

      port = mkOption {
        type = types.ints.u16;
        default = 8089;
        description = "The port to run the service on";
      };

      email = mkOption {
        type = types.str;
        description = "The email address linked to the Epic Games account to fetch free games for";
      };

      ntfy = {
        url = mkOption {
          type = types.str;
          default = "https://ntfy.tlp";
          description = "The ntfy backend url";
        };

        topic = mkOption {
          type = types.str;
          default = "free-epic-games";
          description = "The ntfy backend url";
        };
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
      };

      virtualisation.oci-containers.containers.free-epic-games = let
        name = "free-epic-games";
        version = "5.1.0";
      in {
        image = "${name}:${version}";
        imageFile = pkgs.dockerTools.pullImage {
          imageName = "ghcr.io/claabs/epicgames-freegames-node";
          imageDigest = "sha256:6b54783ea337cde4fe286c22e6e1c4f53ffe0c62c2ffb07de4b3e06c1ee51e80";
          finalImageName = "${name}";
          finalImageTag = "${version}";
          hash = "sha256-JPAjrdZrBolxOOqoGxLBqn84eDWS8B7OJtoQmTtBpjM=";
        };

        volumes = let
          jsonFormat = pkgs.formats.json {};

          settings = {
            runOnStartup = true;
            # Auto accept EULA changes
            notifyEula = true;
            timezone = config.time.timeZone;
            browserNavigationTimeout = 2 * 60 * 1000;
            countryCode = "NL";
            cronSchedule = "0 0,6,12,18 * * *";
            logLevel = "info";

            webPortalConfig = {
              baseUrl = "${cfg.caddy.url}";
            };

            accounts = [
              {
                inherit (cfg) email;
              }
            ];

            notifiers = [
              {
                type = "ntfy";
                webhookUrl = "${cfg.ntfy.url}/${cfg.ntfy.topic}";
                priority = "default";
                token = "";
              }
            ];
          };

          configFile = jsonFormat.generate "free-epic-games" settings;
        in ["${configFile}:/usr/app/config/config.json"];

        ports = ["127.0.0.1:${toString cfg.port}:3000"];
      };
    };
}

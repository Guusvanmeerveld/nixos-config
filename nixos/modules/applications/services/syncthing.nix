{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.services.syncthing;
in {
  options = {
    custom.applications.services.syncthing = {
      enable = lib.mkEnableOption "Enable Syncthing file sync client";

      port = lib.mkOption {
        type = lib.types.int;
        description = "The port to run the service on";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        description = "The external domain the service can be reached from";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      nginx = lib.mkIf config.services.nginx.enable {
        virtualHosts = {
          "${cfg.domain}" = {
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              proxyPass = "http://localhost:${toString cfg.port}/";
              recommendedProxySettings = true;
            };
          };
        };
      };

      syncthing = {
        enable = true;

        guiAddress = "0.0.0.0:${toString cfg.port}";
        openDefaultPorts = true;

        settings = {
          gui = {
            theme = "black";
          };

          options = {
            localAnnounceEnabled = false;
            urAccepted = -1;
          };
        };
      };
    };
  };
}

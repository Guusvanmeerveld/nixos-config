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

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = cfg.enable;
        description = "Open syncthing ports in firewall";
      };

      fileTransferPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 22000;
      };

      discoveryPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 21027;
      };
    };
  };

  config = {
    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [cfg.fileTransferPort cfg.discoveryPort];

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

      syncthing = lib.mkIf cfg.enable {
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

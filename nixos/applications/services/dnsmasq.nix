{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.services.dnsmasq;

  resolvFile = pkgs.writeText "resolve.conf" ''
    ${lib.concatStringsSep "\n" (map (server: "nameserver ${server}") cfg.upstream-servers)}
  '';

  logFile = "/var/log/dnsmasq";
in {
  options = {
    custom.applications.services.dnsmasq = {
      enable = lib.mkEnableOption "Enable dnsmasq DNS service";

      redirects = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};

        description = "Redirect a given domain name to a given ip address";
      };

      upstream-servers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["1.1.1.1"];

        description = "The servers to reroute the dns requests to";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [53];
      allowedUDPPorts = [53];
    };

    services = {
      logrotate = {
        enable = true;

        settings."${logFile}" = {
          enable = true;

          rotate = 3;
          size = "50M";
          notifempty = true;
          compress = true;
          create = "0640 dnsmasq dnsmasq";

          postrotate = ''
            systemctl reload dnsmasq > /dev/null 2>&1 || true
          '';
        };
      };

      dnsmasq = {
        enable = true;

        resolveLocalQueries = false;

        # Add an 'address' line to the config for every redirect.
        extraConfig = ''
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "address=/${name}/${value}") cfg.redirects)}
        '';

        settings = {
          domain-needed = true;

          no-hosts = true;

          resolv-file = toString resolvFile;

          log-facility = logFile;
          log-queries = true;
          log-async = 10;
        };
      };
    };
  };
}

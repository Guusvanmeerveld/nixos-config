{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.services.dnsmasq;

  resolvFile = pkgs.writeText "resolve.conf" ''
    ${lib.concatStringsSep "\n" (map (server: "nameserver ${server}") cfg.upstream-servers)}
  '';

  logFile = "/var/log/dnsmasq";
in {
  options = {
    custom.services.dnsmasq = {
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

      openFirewall = lib.mkEnableOption "Open default firewall ports";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = lib.optional cfg.openFirewall 53;
      allowedUDPPorts = lib.optional cfg.openFirewall 53;
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
            systemctl restart dnsmasq > /dev/null 2>&1 || true
          '';
        };
      };

      dnsmasq = {
        enable = true;

        resolveLocalQueries = false;

        settings = {
          domain-needed = true;

          no-hosts = true;

          resolv-file = toString resolvFile;
          # Add an 'address' line to the config for every redirect.
          address = lib.mapAttrsToList (name: value: "/${name}/${value}") cfg.redirects;

          log-facility = logFile;
          log-queries = true;
          log-async = 10;
        };
      };
    };
  };
}

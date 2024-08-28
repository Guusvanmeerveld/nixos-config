{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.services.dnsmasq;

  resolv-file = pkgs.writeText "resolve.conf" ''
    ${lib.concatStringsSep "\n" (map (server: "nameserver ${server}") cfg.upstream-servers)}
  '';
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

    services.dnsmasq = {
      enable = true;

      resolveLocalQueries = false;

      # Add an 'address' line to the config for every redirect.
      extraConfig = ''
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "address=/${name}/${value}") cfg.redirects)}
      '';

      settings = {
        domain-needed = true;

        no-hosts = true;

        resolv-file = toString resolv-file;
      };
    };
  };
}

{lib, pkgs, ...}: let 
    upstream-servers = ["1.1.1.1"];

    redirects = {
      "mijnmodem.kpn" = "192.168.2.254";
      ".sun" = "192.168.2.119";

      "orchid" = "192.168.2.195";
    };

    resolv-file = pkgs.writeText "resolve.conf" ''
      ${lib.concatStringsSep "\n" (map (server: "nameserver ${server}") upstream-servers)}
    '';
  in {
  config = {
    networking.firewall = {
      allowedTCPPorts = [53];
      allowedUDPPorts = [53];
    };

    services.dnsmasq = {
      enable = true;

      resolveLocalQueries = false;

      # Add an 'address' line to the config for every redirect.
      extraConfig = ''
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "address=/${name}/${value}") redirects)}
      '';

      settings = {
        domain-needed = true;

        no-hosts = true;

        resolv-file = toString (resolv-file);
      };
    };
  };
}

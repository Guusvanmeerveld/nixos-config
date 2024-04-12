{config, ...}: {
  config = {
    services.nginx = {
      enable = true;

      virtualHosts = {
        "bitwarden.guusvanmeerveld.dev" = let
          port = toString config.services.vaultwarden.config.ROCKET_PORT;
        in {
          addSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://localhost:${port}/";
            proxyWebsockets = true;
          };
        };
      };
    };

    networking.firewall = {
      allowedTCPPorts = [80 443];
    };
  };
}

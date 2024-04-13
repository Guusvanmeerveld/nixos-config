{
  config,
  lib,
  ...
}: {
  config = {
    services.nginx = {
      enable = true;

      virtualHosts = {
        "bitwarden.guusvanmeerveld.dev" = lib.mkIf config.services.vaultwarden.enable {
          addSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = let
              port = toString config.services.vaultwarden.config.ROCKET_PORT;
            in "http://localhost:${port}/";
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };
        };

        "webdav.guusvanmeerveld.dev" = lib.mkIf config.services.radicale.enable {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://localhost:5232/";
            recommendedProxySettings = true;
            extraConfig = ''
              proxy_set_header  X-Script-Name /;
              proxy_pass_header Authorization;
            '';
          };
        };
      };
    };

    networking.firewall = {
      allowedTCPPorts = [80 443];
    };
  };
}

{
  pkgs,
  lib,
  ...
}: let
  cachePort = 10500;
in {
  users.users.gitea-runner = {
    isSystemUser = true;
    group = "gitea-runner";
  };

  users.groups.gitea-runner = {
  };

  systemd.services.gitea-runner-default.serviceConfig = {
    DynamicUser = lib.mkForce false;
  };

  services.caddy.virtualHosts = {
    "https://forgejo-cache.sun.guusvanmeerveld.dev" = {
      extraConfig = ''
        reverse_proxy http://localhost:${toString cachePort}
      '';
    };
  };

  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;

    instances.default = {
      enable = true;

      name = "Sunflower Runner";

      url = "https://forgejo.sun.guusvanmeerveld.dev";

      tokenFile = "/secrets/forgejo-runner/tokenFile";

      labels = [
        "ubuntu-latest:docker://node:lts-bullseye"
        "ubuntu-22.04:docker://node:lts-bullseye"
        "ubuntu-20.04:docker://node:lts-bullseye"
        "ubuntu-18.04:docker://node:lts-buster"
      ];

      settings = {
        cache = {
          enabled = true;

          port = cachePort;

          actions_cache_url_override = "https://forgejo-cache.sun.guusvanmeerveld.dev";
        };
      };
    };
  };
}

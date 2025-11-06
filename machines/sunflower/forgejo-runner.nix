{
  pkgs,
  config,
  lib,
  ...
}: {
  users.users.gitea-runner = {
    isSystemUser = true;
    group = "gitea-runner";
  };

  users.groups.gitea-runner = {
  };

  systemd.services.gitea-runner-default.serviceConfig = {
    DynamicUser = lib.mkForce false;
  };

  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;

    instances.default = {
      enable = true;

      name = "Sunflower Runner";

      url = "http://sunflower:${toString config.services.forgejo.settings.server.HTTP_PORT}";

      tokenFile = "/secrets/forgejo-runner/tokenFile";

      labels = [
        "ubuntu-latest:docker://node:lts-bullseye"
        "ubuntu-22.04:docker://node:lts-bullseye"
        "ubuntu-20.04:docker://node:lts-bullseye"
        "ubuntu-18.04:docker://node:lts-buster"
      ];
    };
  };
}

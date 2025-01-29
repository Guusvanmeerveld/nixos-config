{inputs, ...}: {
  imports = [inputs.agenix.nixosModules.default];

  config = {
    age.secrets = {
      gitea = {
        file = ./secrets/gitea.age;
        mode = "770";
        owner = "docker-compose";
        group = "docker";
      };

      nextcloud = {
        file = ./secrets/nextcloud.age;
        mode = "770";
        owner = "docker-compose";
        group = "docker";
      };

      drone = {
        file = ./secrets/drone.age;
        mode = "770";
        owner = "docker-compose";
        group = "docker";
      };

      immich = {
        file = ./secrets/immich.age;
        mode = "770";
        owner = "docker-compose";
        group = "docker";
      };

      gluetun = {
        file = ./secrets/gluetun.age;
        mode = "770";
        owner = "docker-compose";
        group = "docker";
      };

      unifi = {
        file = ./secrets/unifi.age;
        mode = "770";
        owner = "docker-compose";
        group = "docker";
      };

      wireguard-garden = {
        file = ./secrets/wireguard-garden.age;
        mode = "770";
        owner = "systemd-network";
        group = "systemd-network";
      };
    };
  };
}

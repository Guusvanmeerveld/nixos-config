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
    };
  };
}

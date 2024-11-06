{inputs, ...}: {
  imports = [inputs.agenix.nixosModules.default];

  config = {
    age.secrets = {
      feg = {
        file = ./secrets/feg.age;
        owner = "docker-compose";
        group = "docker";
      };
    };
  };
}

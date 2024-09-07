{inputs, ...}: {
  imports = [inputs.agenix.nixosModules.default];

  config = {
    age.secrets.gitea = {
      file = ./secrets/gitea.age;
      mode = "770";
      owner = "docker-compose";
      group = "docker";
    };
  };
}

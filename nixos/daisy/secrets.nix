{inputs, ...}: {
  imports = [inputs.agenix.nixosModules.default];

  age.secrets.jupyter.file = ./secrets/jupyter.age;
}

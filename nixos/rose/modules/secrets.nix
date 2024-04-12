{inputs, ...}: {
  imports = [inputs.agenix.nixosModules.default];

  age.secrets.email-password.file = ./secrets/email-password.age;
}

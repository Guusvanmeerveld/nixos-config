{inputs, ...}: {
  imports = [inputs.agenix.nixosModules.default];

  age.secrets.email-password.file = ./secrets/email-password.age;
  age.secrets.radicale-htpasswd = {
    file = ./secrets/radicale-htpasswd.age;
    owner = "radicale";
  };
}

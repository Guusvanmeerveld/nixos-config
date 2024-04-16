{inputs, ...}: {
  imports = [inputs.agenix.nixosModules.default];

  age.secrets.mailserver-mail-password.file = ./secrets/mailserver-mail-password.age;
  age.secrets.radicale-htpasswd = {
    file = ./secrets/radicale-htpasswd.age;
    owner = "radicale";
  };
  age.secrets.miniflux.file = ./secrets/miniflux.age;
  age.secrets.vaultwarden.file = ./secrets/vaultwarden.age;
}

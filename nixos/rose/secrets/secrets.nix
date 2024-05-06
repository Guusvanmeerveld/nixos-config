let
  rose = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMPKhslDx0+SxtW0BInpztfsUsL7BcuMlWXU2WJjpXW";
in {
  "mailserver-mail-password.age".publicKeys = [rose];
  "radicale-htpasswd.age".publicKeys = [rose];
  "miniflux.age".publicKeys = [rose];
  "vaultwarden.age".publicKeys = [rose];
  "jupyter.age".publicKeys = [rose];
}

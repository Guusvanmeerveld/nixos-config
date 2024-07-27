let
  guus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQHHL8QRobBbpoIkFLDUB+zaF1OVp1X5wWcTz8KXKwh guus@rose";

  users = [guus];

  rose = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMPKhslDx0+SxtW0BInpztfsUsL7BcuMlWXU2WJjpXW root@rose";

  systems = [rose];

  all = users ++ systems;
in {
}

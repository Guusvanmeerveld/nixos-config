let
  guus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDKpY7dWK02mpppMTTX0NG8vJkAWvl6iDNF9wRlIsuna guus@daisy";

  users = [guus];

  daisy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK6X2d/xZs8K+ZoR3JqE8bub2b1nxrxu94Qylg/8fNrp root@daisy";

  systems = [daisy];

  all = systems ++ users;
in {
}
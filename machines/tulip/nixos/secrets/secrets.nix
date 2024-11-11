let
  guus-tulip = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHebmVXbaAaLVgRemix3eJGA6RMmW7qwHS5RH6r4Lwa1";

  users = [guus-tulip];

  tulip = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICJ86Kx0ApSKwYandpbT6TTorgwN1xTzqnJBub6EeXka";
  systems = [tulip];

  all = systems ++ users;
in {
  "gitea.age".publicKeys = all;
  "nextcloud.age".publicKeys = all;
  "drone.age".publicKeys = all;
  "immich.age".publicKeys = all;
  "gluetun.age".publicKeys = all;
}

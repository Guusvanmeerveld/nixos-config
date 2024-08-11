let
  guus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHNrVAIsvzTpfCRiivwSajOva1Xo5AEb3j0DprxwQOFH guus@raspberry";
  users = [ guus ];

  raspberry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPtaQ104THGcDn4v9YSwNvrBnzUS/+WwE8R7Ns0EZXw root@nixos";
  systems = [ raspberry ];

  all = users ++ systems;
in
{
  "spotifyd.age".publicKeys = all;
}
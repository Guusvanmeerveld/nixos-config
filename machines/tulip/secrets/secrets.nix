let
  users = [];

  tulip = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICJ86Kx0ApSKwYandpbT6TTorgwN1xTzqnJBub6EeXka";
  desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF+QqocPEiogC6EJOKiKOCIk93KM8IU49C7YzBZNDJ3H";
  systems = [tulip desktop];

  all = systems ++ users;
in {
  "gitea.age".publicKeys = all;
}

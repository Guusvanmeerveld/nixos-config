let
  desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOu2GL9qwMhGxZmGFCxsctJ2eOf395Fl6Vq/ZwODRi/B";

  systems = [ desktop ];

  guus-desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmI5g/8cOp86kqwirZmPBWxyJpXbHTqFjxdZR4j4O+w";

  users = [ guus-desktop ];
in
{
  "spotifyd.age".publicKeys = users ++ systems;
}

let
  guus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINPu3qzwYtJO7vVWZdLklXtkGbqJpHvkfXSUU0rFE/Rx guus@raspberry";
  users = [guus];

  systems = [];

  all = users ++ systems;
in {
}

{pkgs, ...}: {
  manage-secrets = pkgs.writeShellApplication {
    name = "manage-secrets";

    text = builtins.readFile ./manage-secrets.sh;
  };
}

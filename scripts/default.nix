{pkgs, ...}: {
  backup-secrets = pkgs.writeShellApplication {
    name = "backup-secrets";

    text = builtins.readFile ./backup-secrets.sh;
  };
}

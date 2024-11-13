{pkgs, ...}: {
  backup-ssh-keys = pkgs.writeShellApplication {
    name = "backup-ssh-keys";

    text = ''
      ${./backup-ssh-keys.sh} "$@"
    '';
  };
}

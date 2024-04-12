{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [inputs.simple-nixos-mailserver.nixosModule ./secrets.nix];

  mailserver = {
    enable = true;
    fqdn = "mail2.guusvanmeerveld.dev";
    domains = ["guusvanmeerveld.dev"];

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "mail@guusvanmeerveld.dev" = {
        hashedPasswordFile = config.age.secrets.email-password.path;
        aliases = ["postmaster@guusvanmeerveld.dev"];
      };
    };

    enableManageSieve = true;

    certificateScheme = "acme-nginx";
  };

  services.radicale = {
    enable = true;
    settings = {
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.age.secrets.radicale-htpasswd.path;
        htpasswd_encryption = "bcrypt";
      };

      storage = {
        filesystem_folder = "/var/lib/radicale/collections";
      };
    };
  };
}

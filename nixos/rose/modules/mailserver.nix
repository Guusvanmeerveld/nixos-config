{
  inputs,
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

    certificateScheme = "acme-nginx";
  };
}

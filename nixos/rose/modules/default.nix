{
  imports = [
    # ./mailserver.nix
    ./nginx.nix
    ./vaultwarden.nix
  ];

  config = {
    security.acme.acceptTerms = true;
    security.acme.defaults.email = "security@guusvanmeerveld.dev";
  };
}

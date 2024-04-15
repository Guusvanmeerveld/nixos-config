{
  imports = [
    ./mailserver.nix
    # ./syncthing.nix
    ./miniflux.nix
    ./searx.nix
    ./nginx.nix
    ./vaultwarden.nix
  ];

  config = {
    security.acme.acceptTerms = true;
    security.acme.defaults.email = "security@guusvanmeerveld.dev";
  };
}

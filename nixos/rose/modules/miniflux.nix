{config, ...}: {
  imports = [./secrets.nix];

  config = {
    services.miniflux = {
      enable = true;

      config = {
        CLEANUP_FREQUENCY = "48";
        LISTEN_ADDR = "localhost:8082";
        BASE_URL = "https://miniflux.guusvanmeerveld.dev";
      };

      adminCredentialsFile = config.age.secrets.miniflux.path;
    };
  };
}

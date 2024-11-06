{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.applications.services.docker;

  cfg = dockerConfig.portfolio;
  networking = dockerConfig.networking;
  storage = dockerConfig.storage;

  jsonFormat = pkgs.formats.json {};

  info = import ./info.nix;

  cvFile = jsonFormat.generate "portfolio-cv" info.cv;
  landingFile = jsonFormat.generate "portfolio-landing" info.landing;

  dataDirPackage = pkgs.stdenv.mkDerivation {
    name = "portfolio-data-dir";
    version = "0.1.0";

    phases = ["installPhase"];

    installPhase = ''
      mkdir $out/data -p

      cp ${cvFile} $out/data/cv.json
      cp ${landingFile} $out/data/landing.json
      cp ${./avatar.jpg} $out/data/avatar.jpg
    '';
  };

  dataDir = "${dataDirPackage}/data";

  createPortfolioDir = dir: lib.concatStringsSep "/" [storage.storageDir "portfolio" dir];
in {
  options = {
    custom.applications.services.docker.portfolio = {
      enable = lib.mkEnableOption "Enable immich media streaming service";

      dbDir = lib.mkOption {
        type = lib.types.str;
        default = createPortfolioDir "db";
      };

      # secretsFile = lib.mkOption {
      #   type = lib.types.str;

      #   description = ''
      #     A path to a file that contains the env secrets.
      #     The ones that are required are `SESSION_PASSWORD`
      #   '';
      # };
    };
  };

  config = lib.mkIf cfg.enable {
    services.docker-compose.projects."portfolio" = {
      file = ./docker-compose.yaml;

      networks = [networking.defaultNetworkName];

      env = [
        {
          DATA_DIR = dataDir;
          DB_DIR = cfg.dbDir;

          DB_USER = "portfolio";
          DB_PASSWORD = "portfolio";
          DB_NAME = "portfolio";
        }
      ];
    };
  };
}

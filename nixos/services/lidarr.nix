{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.services.lidarr;
in {
  options = {
    custom.services.lidarr = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable Lidarr";

      webUIPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 8686;
        description = "The port to run the web ui on";
      };

      caddy.url = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "The external domain the service can be reached from";
      };
    };
  };

  config = let
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      custom.services.restic.client.backups.lidarr = {
        services = ["lidarr"];

        files = [
          config.services.lidarr.dataDir
        ];

        excluded = [
          "logs*"
        ];
      };

      nixpkgs.config.permittedInsecurePackages = [
        "dotnet-sdk-6.0.428"
        "aspnetcore-runtime-6.0.36"
      ];

      services = {
        caddy = mkIf (cfg.caddy.url != null) {
          virtualHosts = {
            "${cfg.caddy.url}" = {
              extraConfig = ''
                reverse_proxy http://localhost:${toString cfg.webUIPort}
                tls internal
              '';
            };
          };
        };

        lidarr = {
          enable = true;

          package = pkgs.custom.lidarr-plugins;

          settings = {
            server = {
              urlbase = "localhost";
              port = cfg.webUIPort;
              bindaddress = "*";
            };
          };
        };
      };
    };
}

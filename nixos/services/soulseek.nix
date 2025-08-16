{
  config,
  lib,
  outputs,
  ...
}: let
  cfg = config.custom.services.soulseek;
in {
  imports = [outputs.nixosModules.soularr];

  options = {
    custom.services.soulseek = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable Soulseek";

      port = mkOption {
        type = types.ints.u16;
        default = 3434;
        description = "The port to run the web ui on";
      };

      address = mkOption {
        type = types.str;
        default = "localhost";
        description = "The address the service can be reached on";
      };

      downloadDir = mkOption {
        type = types.path;
        description = "The default location to download files to";
      };

      sharedDirs = mkOption {
        type = with types; listOf path;
        description = "List of directories to share";
      };

      environmentFile = mkOption {
        type = types.path;
        description = "The location to the environment file";
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
      services = {
        caddy = mkIf (cfg.caddy.url != null) {
          virtualHosts = {
            "${cfg.caddy.url}" = {
              extraConfig = ''
                reverse_proxy http://${cfg.address}:${toString cfg.port}
                tls internal
              '';
            };
          };
        };

        soularr = {
          enable = true;
        };

        slskd = {
          enable = true;

          openFirewall = true;

          domain = null;

          inherit (cfg) environmentFile;

          settings = {
            directories = {
              downloads = cfg.downloadDir;
              incomplete = "${cfg.downloadDir}/incomplete";
            };

            shares.directories = cfg.sharedDirs;

            authentication.api_keys = {
              "soularr" = {
                key = builtins.hashString "sha512" "soularr";
                cidr = "0.0.0.0/0,::/0";
              };
            };

            web.port = cfg.port;
          };
        };
      };
    };
}

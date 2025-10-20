{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.soulseek;
in {
  options = {
    custom.services.soulseek = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable Soulseek";

      webUIPort = mkOption {
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
                reverse_proxy http://${cfg.address}:${toString cfg.webUIPort}
                tls internal
              '';
            };
          };
        };

        slskd = {
          enable = true;

          openFirewall = true;

          domain = null;

          user = "lidarr";
          group = "lidarr";

          inherit (cfg) environmentFile;

          settings = {
            directories = {
              downloads = cfg.downloadDir;
            };

            global = {
              upload = {
                slots = 5;
                speed_limit = 5 * 1000; # kibibytes
              };

              limits = {
                queued = {
                  files = 500;
                  megabytes = 5000;
                };

                daily = {
                  files = 1000;
                  megabytes = 50 * 1000;
                  failures = 200;
                };

                weekly = {
                  files = 5000;
                  megabytes = 7 * 50 * 1000;
                  failures = 1000;
                };
              };
            };

            shares.directories = cfg.sharedDirs;

            web = {
              port = cfg.webUIPort;

              authentication.api_keys = {
                lidarr.key = "vbz72HzWIy@vkgw5BZYIr3m&tVpEWbbk";
              };
            };
          };
        };
      };
    };
}

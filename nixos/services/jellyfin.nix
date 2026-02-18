{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.jellyfin;
in {
  options = {
    custom.services.jellyfin = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the Jellyfin service";

      port = mkOption {
        type = types.ints.u16;
        default = 8096;
        description = "The port to run the service on";
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
      custom.services.restic.client.backups.jellyfin = {
        services = ["jellyfin"];

        files = [
          config.services.jellyfin.dataDir
        ];

        excluded = [
          # These can be regenerated after backup, and they use a lot of space
          "metadata"
          "data/introskipper"
          "data/trickplay"
        ];
      };

      # Open port for DLNA
      networking.firewall.allowedUDPPorts = [1900 7359];

      users.users.jellyfin = {
        uid = 7788;
        extraGroups = ["input" "render" "video"];
      };

      users.groups.jellyfin = {
        gid = 7788;
      };

      services = {
        caddy = mkIf (cfg.caddy.url != null) {
          virtualHosts = {
            "${cfg.caddy.url}" = {
              extraConfig = ''
                reverse_proxy http://localhost:${toString cfg.port}
              '';
            };
          };
        };

        jellyfin = {
          enable = true;
        };
      };
    };
}

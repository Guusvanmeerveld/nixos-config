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

        jellyfin.enable = true;
      };
    };
}

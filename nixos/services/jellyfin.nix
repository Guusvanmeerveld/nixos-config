{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.services.jellyfin;
in {
  imports = [
    inputs.jellyfin-plugins.nixosModules.jellyfin-plugins
  ];

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
      users.users.jellyfin = {
        uid = 7788;
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
                tls internal
              '';
            };
          };
        };

        jellyfin = {
          enable = true;

          enabledPlugins = with pkgs.jellyfin-plugins;
          with pkgs.custom.jellyfin; {
            inherit kodisyncqueue intro-skipper;
          };
        };
      };
    };
}

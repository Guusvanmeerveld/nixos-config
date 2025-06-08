{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.services.homeassistant;
in {
  options = {
    custom.services.homeassistant = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the HomeAssistant service";

      port = mkOption {
        type = types.ints.u16;
        default = 8123;
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
                tls internal
              '';
            };
          };
        };

        home-assistant = {
          enable = true;

          config = {
            homeassistant = {
              name = "Guus' home";

              unit_system = "metric";
            };

            http = {
              server_port = cfg.port;
              use_x_forwarded_for = true;
              trusted_proxies = ["::1"];
            };
          };

          customComponents = with pkgs.home-assistant-custom-components; [
            localtuya
          ];

          extraPackages = python3Packages:
            with python3Packages; [
              zlib-ng
              isal
              aiolyric
              gtts
              aiontfy
            ];

          extraComponents = [
            "default_config"
            "met"
            "esphome"
            "hue"
            "ring"
            "wiz"
            "solaredge"
            "traccar"
            "unifi"
            "mobile_app"
          ];
        };
      };
    };
}

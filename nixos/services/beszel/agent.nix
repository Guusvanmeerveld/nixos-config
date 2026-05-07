{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.beszel.agent;
in {
  options = {
    custom.services.beszel.agent = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable Beszel agent";

      environmentFile = mkOption {
        type = types.path;
        default = "/secrets/beszel/agent/environmentFile";
      };

      openFirewall = mkEnableOption "Open firewall ports for agent";
    };
  };

  config = let
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      services.beszel.agent = {
        enable = true;

        smartmon.enable = true;

        inherit (cfg) environmentFile openFirewall;

        environment = {
          HUB_URL = "https://beszel.sun.guusvanmeerveld.dev";
        };
      };
    };
}

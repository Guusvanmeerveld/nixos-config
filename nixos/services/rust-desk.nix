{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.rustdesk;
in {
  options = {
    custom.services.rustdesk = let
      inherit (lib) mkEnableOption;
    in {
      enable = mkEnableOption "Enable Rust-desk remote desktop relay & id server";
    };
  };

  config = let
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      services = {
        rustdesk-server = {
          enable = true;
          openFirewall = true;

          signal.relayHosts = ["sunflower"];
        };
      };
    };
}

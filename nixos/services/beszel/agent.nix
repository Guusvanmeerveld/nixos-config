{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.beszel.agent;
in {
  options = {
    custom.services.beszel.agent = let
      inherit (lib) mkEnableOption;
    in {
      enable = mkEnableOption "Enable Beszel agent";
    };
  };

  config = let
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      services.beszel.agent = {
        enable = true;

        smartmon.enable = true;
      };
    };
}

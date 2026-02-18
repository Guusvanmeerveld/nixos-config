{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.autoUpgrade;
in {
  options = {
    custom.services.autoUpgrade = {
      enable = lib.mkEnableOption "Enable system auto upgrade service";

      flake = lib.mkOption {
        type = lib.types.str;
        description = "The flake uri of the NixOS config to upgrade to";
        default = "github:guusvanmeerveld/nixos-config";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    system.autoUpgrade = {
      enable = true;

      inherit (cfg) flake;

      randomizedDelaySec = "30min";

      dates = "Fri 04:00";
    };
  };
}

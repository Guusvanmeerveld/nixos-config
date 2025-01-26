{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.thunderbird;
in {
  options = {
    custom.programs.thunderbird = {
      enable = lib.mkEnableOption "Enable Thunderbird email client";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.thunderbird = {
      enable = true;

      profiles = {
        "default" = {
          isDefault = true;
        };
      };

      settings = {
        "privacy.donottrackheader.enabled" = true;
      };
    };
  };
}

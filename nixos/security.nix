{
  lib,
  config,
  ...
}: let
  cfg = config.custom.security;
in {
  options = {
    custom.security = {
      keyring = {
        enable = lib.mkEnableOption "Enable keyring";
      };
    };
  };

  config = {
    security.polkit.enable = true;

    services.gnome.gnome-keyring = lib.mkIf cfg.keyring.enable {
      enable = true;
    };
  };
}

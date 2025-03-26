{
  lib,
  config,
  ...
}: let
  cfg = config.custom.networking.mullvad;
in {
  options = {
    custom.networking.mullvad = {
      enable = lib.mkEnableOption "Enable Mullvad VPN client";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mullvad-vpn.enable = true;
  };
}

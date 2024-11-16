{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.hardware.bluetooth;
in {
  options = {
    custom.hardware.bluetooth = {
      enable = lib.mkEnableOption "Enable Bluetooth";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
    };

    services.blueman.enable = true;

    systemd.user.services.mpris-proxy = {
      description = "Mpris proxy";
      after = ["network.target" "sound.target"];
      wantedBy = ["default.target"];
      serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    };
  };
}

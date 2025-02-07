{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.hardware.input.corsair;
in {
  options = {
    custom.hardware.input.corsair.enable = lib.mkEnableOption "Enable Corsair keyboard support application";
  };

  config = lib.mkIf cfg.enable {
    hardware.ckb-next.enable = true;

    environment.systemPackages = [
      (pkgs.makeAutostartItem {
        name = "ckb-next";
        package = pkgs.ckb-next;
      })
    ];
  };
}

{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.hardware.input.corsair;

  package = pkgs.ckb-next.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or []) ++ ["-DUSE_DBUS_MENU=0"];
  });
in {
  options = {
    custom.hardware.input.corsair.enable = lib.mkEnableOption "Enable Corsair keyboard support application";
  };

  config = lib.mkIf cfg.enable {
    hardware.ckb-next = {
      enable = true;

      inherit package;
    };

    environment.systemPackages = [
      (pkgs.makeAutostartItem {
        inherit package;
        name = "ckb-next";
      })
    ];
  };
}

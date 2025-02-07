{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.hardware.video.amd;
in {
  options = {
    custom.hardware.video.amd = {
      enable = lib.mkEnableOption "Enable AMD gpu support";

      vrr.enable = lib.mkEnableOption "Enable Variable Refresh Rate support";
      polaris.enable = lib.mkEnableOption "Enable OpenCL for RX 500 series based GPUs";
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        radeontop
      ];

      variables = lib.mkIf cfg.polaris.enable {
        ROC_ENABLE_PRE_VEGA = "1";
      };
    };

    services.xserver = {
      deviceSection = lib.mkIf cfg.vrr.enable ''
        Option "TearFree" "true"
        Option "VariableRefresh" "true"
      '';

      enable = true;
      videoDrivers = ["amdgpu"];
    };

    boot.initrd.kernelModules = ["amdgpu"];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}

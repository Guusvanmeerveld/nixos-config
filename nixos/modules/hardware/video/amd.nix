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
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      radeontop
    ];

    services.xserver = {
      deviceSection = lib.mkIf cfg.vrr.enable ''
        Option "TearFree" "true"
        Option "VariableRefresh" "true"
      '';

      videoDrivers = ["amdgpu"];
    };

    boot.initrd.kernelModules = ["amdgpu"];

    hardware.opengl.driSupport = true;
    # For 32 bit applications
    hardware.opengl.driSupport32Bit = true;
  };
}

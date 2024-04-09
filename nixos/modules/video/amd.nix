{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.video.amd;
in {
  options = {
    custom.video.amd = {
      enable = lib.mkEnableOption "Enable AMD gpu support";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      radeontop
    ];

    services.xserver = {
      deviceSection = ''
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

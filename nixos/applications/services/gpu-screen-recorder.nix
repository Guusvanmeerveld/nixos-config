{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.services.gpu-screen-recorder;

  package = pkgs.unstable.gpu-screen-recorder;
in {
  options = {
    custom.applications.services.gpu-screen-recorder = {
      enable = lib.mkEnableOption "Enable GSR security wrappers";
    };
  };

  config = lib.mkIf cfg.enable {
    security.wrappers."gsr-kms-server" = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+ep";

      source = "${package}/bin/gsr-kms-server";
    };

    security.wrappers."gpu-screen-recorder" = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_nice+ep";

      source = "${package}/bin/gpu-screen-recorder";
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.fs.zfs;
in {
  options = {
    custom.fs.zfs = {
      enable = lib.mkEnableOption "Enable ZFS file system";
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      supportedFilesystems = ["zfs"];

      zfs = {
        forceImportRoot = false;
      };
    };

    services.zfs.autoScrub.enable = true;

    environment.systemPackages = with pkgs; [zfs];
  };
}

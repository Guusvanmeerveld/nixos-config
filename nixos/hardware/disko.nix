{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.custom.hardware.disko;
in {
  imports = [inputs.disko.nixosModules.disko];

  options = {
    custom.hardware.disko = {
      enable = lib.mkEnableOption "Enable Disko disk management";

      device = lib.mkOption {
        type = lib.types.str;
        description = "The disk to use as the main boot drive";
      };

      swap = {
        size = lib.mkOption {
          type = lib.types.str;
          description = "How large the swap partition should be";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = cfg.device;

          content = {
            type = "gpt";

            partitions = {
              ESP = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = ["umask=0077" "dmask=0077" "defaults"];
                };
              };

              swap = {
                size = cfg.swapSize;
                content = {
                  type = "swap";
                  discardPolicy = "both";
                  resumeDevice = true; # resume from hiberation from this device
                };
              };

              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
}

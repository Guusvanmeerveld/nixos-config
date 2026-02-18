{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.linux;
in {
  options = {
    custom.linux = {
      cachyos.useKernel = lib.mkEnableOption "Use the CachyOS kernel instead of the default Linux kernel";
    };
  };

  config = lib.mkIf cfg.cachyos.useKernel {
    nix.settings = {
      trusted-public-keys = [
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      ];

      substituters = [
        "https://attic.xuyh0120.win/lantian"
      ];
    };

    boot = {
      # Replace kernel by CachyOS kernel
      kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
      zfs.package = config.boot.kernelPackages.zfs_cachyos;
    };
  };
}

{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.office.trilium-desktop;
in {
  options = {
    custom.programs.office.trilium-desktop = {
      enable = lib.mkEnableOption "Enable Trilium Desktop";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [trilium-desktop];
  };
}

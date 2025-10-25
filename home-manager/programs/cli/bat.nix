{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.cli.bat;
in {
  options = {
    custom.programs.cli.bat = {
      enable = lib.mkEnableOption "Enable Bat, a cat clone with extra's";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.bat = {
      enable = true;

      extraPackages = with pkgs.bat-extras; [
        batdiff
        batman
        # TODO: re-enable batgrep when its fixed:
        # https://github.com/NixOS/nixpkgs/issues/454391
        # batgrep
        batwatch
        prettybat
      ];
    };
  };
}

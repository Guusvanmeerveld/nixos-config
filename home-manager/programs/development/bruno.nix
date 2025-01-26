{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.development.bruno;
in {
  options = {
    custom.programs.development.bruno = {
      enable = lib.mkEnableOption "Enable Bruno API client";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [bruno];
  };
}

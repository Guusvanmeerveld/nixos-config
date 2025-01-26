{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.cantata;
in {
  options = {
    custom.programs.cantata = {
      enable = lib.mkEnableOption "Enable Cantata MPD client";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      cantata
    ];
  };
}

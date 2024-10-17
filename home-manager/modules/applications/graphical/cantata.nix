{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.cantata;
in {
  options = {
    custom.applications.graphical.cantata = {
      enable = lib.mkEnableOption "Enable Cantata MPD client";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      cantata
    ];
  };
}

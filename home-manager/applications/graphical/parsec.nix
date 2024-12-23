{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.parsec;
in {
  options = {
    custom.applications.graphical.parsec = {
      enable = lib.mkEnableOption "Enable Parsec remote streaming program";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [parsec-bin];

    allowedUnfree = ["parsec-bin"];
  };
}

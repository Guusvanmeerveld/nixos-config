{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.development.unity;
in {
  options = {
    custom.applications.graphical.development.unity = {
      enable = lib.mkEnableOption "Enable Unity hub";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [unityhub ffmpeg];

    allowedUnfree = ["unityhub"];

    custom.applications.development.python.enable = true;
  };
}

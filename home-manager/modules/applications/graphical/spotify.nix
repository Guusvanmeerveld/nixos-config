{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.spotify;
in {
  options = {
    custom.applications.graphical.spotify = {
      enable = lib.mkEnableOption "Enable Spotify music application";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [spotifywm];
  };
}

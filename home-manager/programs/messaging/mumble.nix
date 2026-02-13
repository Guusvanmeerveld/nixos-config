{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.messaging.mumble;
in {
  options = {
    custom.programs.messaging.mumble = {
      enable = lib.mkEnableOption "Enable Mumble client";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      mumble
    ];
  };
}

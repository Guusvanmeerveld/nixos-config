{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.messaging.whatsapp;
in {
  options = {
    custom.applications.graphical.messaging.whatsapp = {
      enable = lib.mkEnableOption "Enable Whatsapp for Linux";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      whatsapp-for-linux
    ];
  };
}

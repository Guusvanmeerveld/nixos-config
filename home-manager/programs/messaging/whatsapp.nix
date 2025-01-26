{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.messaging.whatsapp;
in {
  options = {
    custom.programs.messaging.whatsapp = {
      enable = lib.mkEnableOption "Enable Whatsapp for Linux";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      whatsapp-for-linux
    ];
  };
}

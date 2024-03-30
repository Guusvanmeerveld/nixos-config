{ lib, config, pkgs, ... }:
let cfg = config.custom.applications.graphical.messaging.discord; in
{
  options = {
    custom.applications.graphical.messaging.discord = {
      enable = lib.mkEnableOption "Enable Discord client";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ armcord ];
  };
}


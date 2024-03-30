{ lib, config, pkgs, ... }:
let cfg = config.custom.applications.graphical.development.bruno; in
{
  options = {
    custom.applications.graphical.development.bruno = {
      enable = lib.mkEnableOption "Enable Bruno API client";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ bruno ];
  };
}


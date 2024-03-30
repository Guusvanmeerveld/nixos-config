{ lib, config, pkgs, ... }:
let cfg = config.custom.applications.graphical.office.libreoffice; in
{
  options = {
    custom.applications.graphical.office.libreoffice = {
      enable = lib.mkEnableOption "Enable Libre office suite";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      libreoffice
      hunspellDicts.nl_nl
      hunspellDicts.en-us
    ];
  };
}


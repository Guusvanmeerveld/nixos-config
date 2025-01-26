{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.office.libreoffice;
in {
  options = {
    custom.programs.office.libreoffice = {
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

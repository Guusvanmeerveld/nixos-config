{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.office.latex;
in {
  options = {
    custom.applications.graphical.office.latex = {
      enable = lib.mkEnableOption "Enable Latex";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      texlive.combined.scheme-full
    ];
  };
}

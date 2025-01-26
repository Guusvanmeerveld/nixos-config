{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.office.latex;
in {
  options = {
    custom.programs.office.latex = {
      enable = lib.mkEnableOption "Enable Latex";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      texlive.combined.scheme-full
    ];
  };
}

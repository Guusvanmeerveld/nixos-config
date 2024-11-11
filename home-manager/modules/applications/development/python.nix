{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.development.python;
in {
  options = {
    custom.applications.development.python = {
      enable = lib.mkEnableOption "Enable Python lang support";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.custom.pythonPackages.pyjags
      (pkgs.python3.withPackages (python-pkgs:
        with python-pkgs; [
          pandas
          numpy
          scikit-learn
          matplotlib
          ipykernel
          jupyter
          scipy
          autopep8
          seaborn
        ]))
    ];
  };
}

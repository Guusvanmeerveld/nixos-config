{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.graphical.development;
in {
  imports = [./vscode.nix ./bruno.nix ./unity.nix];

  options = {
    custom.applications.graphical.development = {
      enable = lib.mkEnableOption "Enable default development applications";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.applications.graphical.development = {
      vscode.enable = true;
      bruno.enable = true;
      unity.enable = true;
    };
  };
}

{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.development;
in {
  imports = [./vscode.nix ./bruno.nix ./unity.nix ./digital.nix];

  options = {
    custom.programs.development = {
      enable = lib.mkEnableOption "Enable default development applications";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.programs.development = {
      vscode.enable = true;
      bruno.enable = true;
    };
  };
}

{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.cli.direnv;
in {
  options = {
    custom.programs.cli.direnv = {
      enable = lib.mkEnableOption "Enable Direnv";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;

      nix-direnv.enable = true;
    };
  };
}

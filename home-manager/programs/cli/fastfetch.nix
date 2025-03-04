{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.cli.fastfetch;
in {
  options = {
    custom.programs.cli.fastfetch = {
      enable = lib.mkEnableOption "Enable fastfetch";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.fastfetch = {
      enable = true;
    };
  };
}

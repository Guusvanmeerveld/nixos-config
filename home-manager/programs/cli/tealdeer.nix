{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.cli.tealdeer;
in {
  options = {
    custom.programs.cli.tealdeer = {
      enable = lib.mkEnableOption "Enable Teal Deer tldr program";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.tealdeer = {
      enable = true;
      settings = {
        updates = {
          auto_update = true;
        };
      };
    };
  };
}

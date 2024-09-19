{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.shell.tealdeer;
in {
  options = {
    custom.applications.shell.tealdeer = {
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

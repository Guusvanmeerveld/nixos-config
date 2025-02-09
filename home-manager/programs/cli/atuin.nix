{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.cli.atuin;
in {
  options = {
    custom.programs.cli.atuin = {
      enable = lib.mkEnableOption "Enable Atuin history sync";

      server = lib.mkOption {
        type = lib.types.str;
        description = "The remote Atuin server to connect to";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.atuin = {
      enable = true;

      settings = {
        sync_address = cfg.server;
        auto_sync = true;
        sync_frequency = "5m";
        search_mode = "prefix";
        enter_accept = false;
      };
    };
  };
}

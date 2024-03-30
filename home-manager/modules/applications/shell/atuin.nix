{ lib, config, pkgs, ... }:
let
  cfg = config.custom.applications.shell.atuin;
  shell = config.custom.applications.shell;
in
{
  imports = [ ./zsh.nix ];

  options = {
    custom.applications.shell.atuin = {
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
      package = pkgs.unstable.atuin;
      enableZshIntegration = shell.zsh.enable;

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

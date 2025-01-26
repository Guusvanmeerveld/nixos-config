{
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.shell.nix-index;
in {
  imports = [inputs.nix-index-database.hmModules.nix-index];

  options = {
    custom.applications.shell.nix-index = {
      enable = lib.mkEnableOption "Enable nix-index database";
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      nix-index.enable = true;
      nix-index-database = {
        comma.enable = true;
      };
    };
  };
}

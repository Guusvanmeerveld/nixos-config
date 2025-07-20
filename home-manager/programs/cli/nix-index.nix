{
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.cli.nix-index;
in {
  imports = [inputs.nix-index-database.homeModules.nix-index];

  options = {
    custom.programs.cli.nix-index = {
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

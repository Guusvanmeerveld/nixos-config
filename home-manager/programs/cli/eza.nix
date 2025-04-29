{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.cli.eza;
in {
  options = {
    custom.programs.cli.eza = {
      enable = lib.mkEnableOption "Enable Eza ls replacement";
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      zsh.shellAliases = {
        ls = "eza";
      };

      eza = {
        enable = true;
        icons = "always";
        git = true;
      };
    };
  };
}

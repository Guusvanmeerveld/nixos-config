{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.zsh;
in {
  options = {
    custom.programs.zsh = {
      enable = lib.mkEnableOption "Enable ZSH shell";
    };
  };

  config =
    lib.mkIf cfg.enable
    {
      users.defaultUserShell = pkgs.zsh;
      programs.zsh.enable = true;
    };
}
